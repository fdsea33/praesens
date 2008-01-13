class Accountancy::OperationsController < ApplicationController

  auto_complete_for :entry, :account, :label
  auto_complete_for :accountancy, :losses, :label
  auto_complete_for :accountancy, :profits, :label
  auto_complete_for :accountancy, :newyear, :name
  auto_complete_for :journal, :nature, :name
  auto_complete_for :journal, :counterpart, :label

  def index
  end
  
  def select_journal_for_entries
    if request.post?
      current_journal_id = params[:entries][:journal_id]
      session[:journal_record_already_created] = false
      redirect_to :action=>:record_entries, :id=>current_journal_id if current_journal_id
    else
      @journals = @current_company.allowed_journals
    end
  end
  
  def record_entries
    session[:current_journal_id] = params[:id]
    @journal = Journal.find(session[:current_journal_id])
    @journal_records = @journal.last_records(5)
    @journal_record = JournalRecord.new(:journal_id=>session[:current_journal_id], :company_id=>@current_company_id)
    @entry = Entry.new(:company_id=>@current_company_id)
    @title = 'Recording entries on x'.t @journal.name
  end
  
  def create_entry
    if request.post?
      journal_is_saved = true
      # Creation of the journal record
      unless session[:journal_record_already_created]
        params[:journal_record][:journal_id] = session[:current_journal_id]
        params[:journal_record][:company_id] = @current_company_id
        @journal_record = JournalRecord.new(params[:journal_record])
        if @journal_record.save
          session[:journal_record_already_created] = true
          session[:current_journal_record_id] = @journal_record.id
        else
          journal_is_saved = false
        end
      else
        @journal_record = JournalRecord.find(session[:current_journal_record_id])
      end
      
      # Recherche du compte
      @account = @current_company.accounts.find(:first, :conditions=>{:number=>params[:account][:number]})
      
      # Creation of the entry
      params[:entry][:company_id] = @current_company_id
      params[:entry][:account_id] = @account.id if @account
      params[:entry][:record_id]  = @journal_record.id
      @entry = Entry.new(params[:entry])
      if @entry.save
        if @entry.record.balance==0
          session[:journal_record_already_created]=false
          @journal_record = JournalRecord.new(:journal_id=>session[:current_journal_id], :company_id=>@current_company_id)
        end
        @entry = Entry.new(:company_id=>@current_company_id)
      end
      @journal = Journal.find(session[:current_journal_id])
      @journal_records = @journal.last_records(5)
      @title = 'Recording entries on x'.t @journal.name
      render :action=>:record_entries, :id=>session[:current_journal_id]
    else
      redirect_to :action=>:select_journal_for_entries
    end
  end
  
  def create_test_data
    bank1     = Account.find_or_create_by_company_id_and_number_and_name(@current_company_id,"51211","Compte courant à la BNP Générale Lyonnaise")
    bank2     = Account.find_or_create_by_company_id_and_number_and_name(@current_company_id,"51212","Compte second à HSBC Courtois du Nord")
    tva       = Account.find_by_company_id_and_number(@current_company_id,"4457104")
    sales     = @current_company.accountancy.sales
    purchases = @current_company.accountancy.purchases
    currency  = @current_company.accountancy.currency
    banks     = Journal.find_by_company_id_and_code(@current_company_id, "BQ")
    a4011 = Account.find_by_company_id_and_number(@current_company_id,"4011").id
    a4111 = Account.find_by_company_id_and_number(@current_company_id,"4111").id
    a6064 = Account.find_by_company_id_and_number(@current_company_id,"6064").id
    a7071 = Account.find_by_company_id_and_number(@current_company_id,"7071").id
    number = 50+(20*rand).round
    for x in 1..number
      price = ((rand*100000).round).to_f/100
      tax   = price*0.196
      total = price+tax
      ecode, pcode = (rand*8+1).round.to_s.rjust(4,"0"), (rand*60+1).round.to_s.rjust(4,"0")
      datex = Date.civil(2007,(3*rand).round+9,(29*rand).round+1)
      bank = rand.round==0 ? bank2 : bank1
      if (19*rand).round<=7
        entity  = Account.find_or_create_by_company_id_and_number_and_name_and_parent_id(@current_company_id,"4011"+ecode,"Fournisseur "+ecode, a4011)
        product = Account.find_or_create_by_company_id_and_number_and_name_and_parent_id(@current_company_id,"6064"+pcode,"Produit "+pcode, a6064)
        # Achats
        record   = JournalRecord.create!(:journal=>purchases, :printed_on=>datex, :number=>purchases.new_record_number)
        Entry.create! :record=>record, :account=>product, :name=>product.name, :currency=>currency, :currency_debit=>price
        Entry.create! :record=>record, :account=>tva, :name=>tva.name, :currency=>currency, :currency_debit=>tax
        Entry.create! :record=>record, :account=>entity, :name=>entity.name, :currency=>currency, :currency_credit=>total
        record   = JournalRecord.create!(:journal=>banks, :printed_on=>datex, :number=>banks.new_record_number)
        Entry.create! :record=>record, :account=>entity, :name=>entity.name, :currency=>currency, :currency_debit=>total
        Entry.create! :record=>record, :account=>bank, :name=>bank.name, :currency=>currency, :currency_credit=>total
      else
        # Ventes
        entity  = Account.find_or_create_by_company_id_and_number_and_name_and_parent_id(@current_company_id,"4111"+ecode,"Client "+ecode, a4111)
        product = Account.find_or_create_by_company_id_and_number_and_name_and_parent_id(@current_company_id,"7071"+pcode,"Produit "+pcode, a7071)
        record   = JournalRecord.create!(:journal=>sales, :printed_on=>datex, :number=>sales.new_record_number)
        Entry.create! :record=>record, :account=>entity, :name=>entity.name, :currency=>currency, :currency_debit=>total
        Entry.create! :record=>record, :account=>product, :name=>product.name, :currency=>currency, :currency_credit=>price
        Entry.create! :record=>record, :account=>tva, :name=>tva.name, :currency=>currency, :currency_credit=>tax
        record   = JournalRecord.create!(:journal=>banks, :printed_on=>datex, :number=>banks.new_record_number)
        Entry.create! :record=>record, :account=>bank, :name=>bank.name, :currency=>currency, :currency_debit=>total
        Entry.create! :record=>record, :account=>entity, :name=>entity.name, :currency=>currency, :currency_credit=>total
      end
    end
    redirect_to :action=>:record_entries, :id=>session[:current_journal_id]
  end

  def journal_list
    @journal_pages, @journals = paginate :journals, :per_page => 30, :conditions => ["company_id=?",@current_company_id], :order=>:name
  end  
  
  def journal_show
    @journal = Journal.find_by_company_id_and_id(@current_company_id, params[:id])
    if @journal
      @title = Journal.localized_model_name+" &raquo; "+@journal.name 
      @journal_periods = @journal.periods
    else
      flash.now[:notice] = "authorization:page_not_authorized".t  action_name
      redirect_to :action=>:journal_list
    end
  end
  
  def curr(x)
    c = Iconv.new 'ISO8859-15', 'UTF-8'
    x==0 ? '' : c.iconv(sprintf("%16.2f",x).strip)
  end


  
  def journal_print
    if request.post?
#      flash[:notice] = params.keys.to_sentence+" &bull; "+ params.values.collect{|x| if x.is_a?(Array); x.to_sentence; else; x.to_s; end;}.to_sentence
#      return
      entries = []
      journal = @current_company.journals.find_by_id(params[:id])
      if journal.nil?
        flash[:error] = "Journal introuvable !"
        return
      end
      if params[:journal][:period] == "dates"
        entries = @current_company.all_entries(['journal_records.journal_id=? AND journal_records.created_on between ? and ?',journal.id,params[:journal][:started_on],params[:journal][:stopped_on]],"journal_records.number ASC")
        title = "Journal j from x to y".t(journal.name,params[:journal][:started_on],params[:journal][:stopped_on])
      else
        financialyear_id = params[:journal][:financialyear_id]
        financialyear = Financialyear.find_by_id_and_company_id(financialyear_id, @current_company_id)
        entries = @current_company.all_entries(['financialyear_id = ?',financialyear_id],"journal_records.number ASC")
        if financialyear.closed
          title = "Journal j of the year x".t(financialyear.code)
        else
          title = "Temporary journal j of the year x".t(financialyear.code)
        end
      end
      if entries.nil?
        flash[:error] = "Entries! #{params[:journal][:period]}, #{params[:journal][:started_on].nil?.to_s}"
      end
#      return
      c = Iconv.new 'ISO8859-15', 'UTF-8'
      pdf = PortableDocument.new;
      pdf.set_title(title)
      pdf.set_subject(title)
      pdf.set_keywords(title)
      pdf.set_creator('Praesens')
      pdf.add_page();
      pdf.set_font('Arial','B',16);
      pdf.cell(190,4,'',0,1,'C');
      pdf.cell(190,12,c.iconv(title),0,1,'C');
      pdf.set_font('Arial','I',12);
      pdf.cell(190,6,c.iconv('en euros'),0,1,'C');
      pdf.cell(190,6,'',0,1,'C');
      pdf.set_font('Times','',8);
      header = ['Date','N°Pièce','Compte','Libellé','Débit','Crédit']
      w=[24,14,28,82,20,20]
      pdf.set_fill_color(32)
      pdf.set_text_color(255)
      pdf.set_draw_color(32)
      pdf.set_line_width(0.1)
      pdf.set_font('','B')
      s=0
      w.each{|x| s = s+x}
      for i in 0..header.size-1
        pdf.cell(w[i],4,c.iconv(header[i]),1,0,'C',1)
      end
      pdf.ln

#      pdf.set_fill_color(224,235,255)
      pdf.set_text_color(0)
      pdf.set_font('')

      pdf.set_fill_color(255,255,255)
      for entry in entries
        if entry.record.number % 2 == 0
          pdf.set_fill_color(224,235,255)
        else
          pdf.set_fill_color(255,255,255)
        end
        pdf.cell(w[0],4,c.iconv(entry.record.created_on.to_formatted_s(:medium)),'LRTB',0,'C',1)
        pdf.cell(w[1],4,c.iconv(entry.record.number.to_s),'LRTB',0,'C',1)
        pdf.cell(w[2],4,c.iconv(entry.account.number),'LRTB',0,'L',1)
        pdf.cell(w[3],4,c.iconv(entry.account.name),'LRTB',0,'L',1)
        pdf.cell(w[4],4,curr(entry.debit),'LRTB',0,'R',1)
        pdf.cell(w[5],4,curr(entry.credit),'LRTB',0,'R',1)
        pdf.ln
      end
      pdf.cell(s,0,'','T')
      pdf.ln
      send_data pdf.render, :filename => 'journal.pdf', :type => "application/pdf"
    else
  
    end
  end
  













  
  def print_general_journal
    @journals = @current_company.journals
    @months = []
		if @current_company.first_financialyear.nil?
      flash[:error] = "There is no opened financial years".t
			redirect_to :action=>:journal_list
			return
		end
    the_date = @current_company.first_financialyear.started_on.beginning_of_month
    stop_date = ::Date.today.beginning_of_month
    while the_date<=stop_date
      @months << [the_date.to_formatted_s(:month), the_date.month.to_s+"."+the_date.year.to_s]
      the_date = the_date>>1
    end
    if request.post?
      if params[:journal][:period] == "dates"
        if params[:journal][:from_month].nil? or params[:journal][:to_month].nil?
          flash[:error] = "The months are incorrects".t
          return
        end
        sta = params[:journal][:from_month].split '.'
        sto = params[:journal][:to_month].split '.'
        started_on = Date.civil(sta[1].to_i,sta[0].to_i,15)
        stopped_on = Date.civil(sto[1].to_i,sto[0].to_i,15)
        if started_on.nil? or stopped_on.nil? or stopped_on<started_on
          flash[:error] = "The months are incorrects".t
          return
        end
        title = "General journal from x to y".t(started_on.to_formatted_s(:month),stopped_on.to_formatted_s(:month))
      else
        financialyear_id = params[:journal][:financialyear_id]
        financialyear = Financialyear.find_by_id_and_company_id(financialyear_id, @current_company_id)
        if financialyear.closed
          title = "General journal of the year x".t(financialyear.code)
        else
          title = "Temporary general journal of the year x".t(financialyear.code)
        end
      end
      #Journals
      journals = []
      for journal in @journals
        if params[:journal]["journal_#{journal.code}".to_sym]=="1"
          journals << journal
        end
      end
      # Begin PDF
      c = Iconv.new 'ISO8859-15', 'UTF-8'
      pdf = PortableDocument.new;
      pdf.set_title(title)
      pdf.set_subject(title)
      pdf.set_keywords(title)
      pdf.set_creator('Praesens')
      pdf.add_page();
      pdf.set_font('Arial','B',16);
      pdf.cell(190,4,'',0,1,'C');
      pdf.cell(190,12,c.iconv(title),0,1,'C');
      pdf.set_font('Arial','I',12);
      pdf.cell(190,6,c.iconv('en euros'),0,1,'C');
      pdf.cell(190,6,'',0,1,'C');
      pdf.set_font('Times','',8);
      header = ['Journal','Débit','Crédit','Débit','Crédit']
      w=[108,20,20,20,20]
      pdf.set_line_width(0.1)
      pdf.set_font('','B')
      s=0
      w.each{|x| s = s+x}

      pdf.set_fill_color(255,255,255)
      pdf.set_text_color(0)
      pdf.set_font('')

          pdf.set_fill_color(96)
          pdf.set_text_color(255)
          pdf.set_draw_color(96)
          pdf.set_font('','B')
          pdf.cell(w[0],4,'')
          pdf.cell(w[1]+w[2],4,c.iconv("Cumul".t),'LRTB',0,'C',1)
          pdf.cell(w[3]+w[4],4,c.iconv("Solde".t),'LRTB',0,'C',1)
          pdf.ln

      # Month
      if params[:journal][:detail]=="1"
        the_date = started_on
        while the_date<=stopped_on
          pdf.set_fill_color(96)
          pdf.set_text_color(255)
          pdf.set_draw_color(96)
          pdf.set_font('','B')
          pdf.cell(w[0],4,c.iconv(the_date.to_formatted_s(:month)),'LRTB',0,'C',1)
          pdf.cell(w[1],4,c.iconv(header[1]),'LRTB',0,'C',1)
          pdf.cell(w[2],4,c.iconv(header[2]),'LRTB',0,'C',1)
          pdf.cell(w[3],4,c.iconv(header[3]),'LRTB',0,'C',1)
          pdf.cell(w[4],4,c.iconv(header[4]),'LRTB',0,'C',1)
          pdf.ln
          pdf.set_fill_color(255,255,255)
          pdf.set_text_color(0)
          pdf.set_font('','')
          debit  = 0.0.to_d
          credit = 0.0.to_d
          for journal in journals
            pdf.cell(w[0],4,c.iconv(journal.name),'LRTB',0,'L',1)
            period = journal.period_at(the_date)
            debit  += period.debit
            credit += period.credit
            bal = period.debit-period.credit
            pdf.cell(w[1],4,curr(period.debit),'LRTB',0,'R',1)
            pdf.cell(w[2],4,curr(period.credit),'LRTB',0,'R',1)
            pdf.cell(w[3],4,curr(bal>0 ? bal : 0),'LRTB',0,'R',1)
            pdf.cell(w[4],4,curr(bal<0 ? -bal : 0),'LRTB',0,'R',1)
            pdf.ln
          end
          bal = debit-credit
          pdf.set_fill_color(224,240,255)
          pdf.set_font('','B')
          pdf.cell(w[0],4,c.iconv('Totaux'),'LRTB',0,'L',1)
          pdf.cell(w[1],4,curr(debit),'LRTB',0,'R',1)
          pdf.cell(w[2],4,curr(credit),'LRTB',0,'R',1)
          pdf.cell(w[3],4,curr(bal>0 ? bal : 0),'LRTB',0,'R',1)
          pdf.cell(w[4],4,curr(bal<0 ? -bal : 0),'LRTB',0,'R',1)
          pdf.ln
#          pdf.cell(s,6,'','')
#          pdf.ln
          the_date = the_date>>1
        end
      end
      
      # Total de la periode
          pdf.cell(s,2,'','')
          pdf.ln
      pdf.set_fill_color(96)
      pdf.set_text_color(255)
#      pdf.cell(w[0],4,'')
#      pdf.cell(w[1]+w[2],4,c.iconv("Cumul".t),'LRTB',0,'C',1)
#      pdf.cell(w[3]+w[4],4,c.iconv("Solde".t),'LRTB',0,'C',1)
#      pdf.ln
      pdf.cell(w[0],4,c.iconv('Period from %s to %s'.t(started_on.to_formatted_s(:month),stopped_on.to_formatted_s(:month))),'LRTB',0,'C',1)
      pdf.cell(w[1],4,c.iconv(header[1]),'LRTB',0,'C',1)
      pdf.cell(w[2],4,c.iconv(header[2]),'LRTB',0,'C',1)
      pdf.cell(w[3],4,c.iconv(header[3]),'LRTB',0,'C',1)
      pdf.cell(w[4],4,c.iconv(header[4]),'LRTB',0,'C',1)

      pdf.ln
      pdf.set_fill_color(255)
      pdf.set_text_color(0)
      debit  = 0.0.to_d
      credit = 0.0.to_d
      for journal in journals
        periods = journal.periods_at(started_on,stopped_on)
        debit  += periods["debit"]
        credit += periods["credit"]
        bal = periods["balance"]
        pdf.cell(w[0],4,c.iconv(journal.name),'LRTB',0,'L',1)
        pdf.cell(w[1],4,curr(periods["debit"]),'LRTB',0,'R',1)
        pdf.cell(w[2],4,curr(periods["credit"]),'LRTB',0,'R',1)
        pdf.cell(w[3],4,curr(bal>0 ? bal : 0),'LRTB',0,'R',1)
        pdf.cell(w[4],4,curr(bal<0 ? -bal : 0),'LRTB',0,'R',1)
        pdf.ln
      end
      bal = debit-credit
      pdf.set_fill_color(224,240,255)
      pdf.cell(w[0],4,c.iconv('Totaux'),'LRTB',0,'L',1)
      pdf.cell(w[1],4,curr(debit),'LRTB',0,'R',1)
      pdf.cell(w[2],4,curr(credit),'LRTB',0,'R',1)
      pdf.cell(w[3],4,curr(bal>0 ? bal : 0),'LRTB',0,'R',1)
      pdf.cell(w[4],4,curr(bal<0 ? -bal : 0),'LRTB',0,'R',1)
      pdf.ln

      send_data pdf.render, :filename => 'general_journal.pdf', :type => "application/pdf"
    else
  
    end
  end
  












  def journal_new
    if request.post?
      params[:journal][:company_id] = @current_company_id
      @journal = Journal.new params[:journal]
      if @journal.save
        redirect_to :action=>:journal_list
      end
    else
      @journal = Journal.new :company_id=>@current_company_id
    end
  end
  
  def journal_edit
    @journal = Journal.find_by_company_id_and_id(@current_company_id, params[:id])
    if request.post?
      params[:journal][:company_id] = @current_company_id
      if @journal.update_attributes params[:journal]
        redirect_to :action=>:journal_list
      end
    end
  end
  
  def journal_close
    @journal = Journal.find_by_company_id_and_id(@current_company_id, params[:id])
    if request.post?
      closed_on = ActiveRecord::ConnectionAdapters::Column.string_to_date(params[:journal][:closed_on])
      error_report = @journal.close(closed_on)
      if error_report.nil?
        redirect_to :action=>:journal_show, :id=>@journal.id
      else
        flash.now[:error] = error_report.t
      end
    else
      @journal.closed_on = (Date.today<<1).end_of_month
    end
  end
  
  def financialyear_list
    @years = []
    @max_fyears = 0
    for year in @current_company.financialyear_natures
      fyears = year.financialyears
      unless fyears.nil?
        @max_fyears = fyears.size if fyears.size>@max_fyears
      end
      @years << [year, fyears]
    end
    
  end  
  
  def financialyear_open
    if request.post?
      params[:financialyear][:nature_id]    = session[:current_financialyear_nature_id]
      params[:financialyear][:company_id] = @current_company_id
#      params[:financialyear][:written_on] = params[:financialyear][:stopped_on]
      @financialyear = Financialyear.new(params[:financialyear])
      if @financialyear.save
        session[:current_financialyear_nature_id] = nil
        redirect_to :action=>:financialyear_list
      end
    else
      session[:current_financialyear_nature_id] = params[:id]
      financialyear_nature = FinancialyearNature.find(session[:current_financialyear_nature_id])
      unless financialyear_nature.can_open_financialyear?
        flash[:error] = "Only one financial year can be opened by type at the same time".t
        redirect_to :action=>:financialyear_list
        return
      end
      @financialyear = Financialyear.new :nature_id=>session[:current_financialyear_nature_id]
    end
  end

  def financialyear_close
    @financialyear = Financialyear.find(params[:id])
    @accountancy = @current_company.accountancy
    if request.post?
      # Enregistrement du paramétrage
      if @accountancy.update_attributes(params[:accountancy])
        # Clôture de l'exercice
        stopped_on = ActiveRecord::ConnectionAdapters::Column.string_to_date(params[:financialyear][:stopped_on])
        error_report = @financialyear.close(stopped_on)
        if error_report.nil?
          redirect_to :action=>:financialyear_list
        else
          flash.now[:error] = error_report.t
        end
      end
    else
      if @financialyear.closed
        flash[:error] = "This financial year is already closed".t
        redirect_to :action=>:financialyear_list
        return
      else
        today = ::Date.today
        if today < @financialyear.stopped_on
          stopped_on = Date.civil(today.year, today.month, 1)-1
          @financialyear.stopped_on = stopped_on if stopped_on>@financialyear.started_on
        end
      end
    end
  end  

  def financialyear_edit
    @financialyear = Financialyear.find(params[:id])
    if @financialyear.closed
      flash[:error] = "This financial year is already closed".t
      redirect_to :action=>:financialyear_list
    else
      if request.post?
        # permet de récupérer que les champs voulus
        p = {}
        p[:code] = params[:financialyear][:code]
        if @financialyear.update_attributes(p)
          redirect_to :action=>:financialyear_list
        end
      end
    end
  end

  def zzz
        begin
      rescue => exc
        flash.now[:error] = exc.class.to_s+" : "+exc.message.t+"<br/>"+"<pre>"+exc.backtrace.join("<br/>")+"</pre>"
      else
        flash[:notice] = "This financial year was successfully closed".t
        redirect_to :action=>:financialyear_list
        return
      end
  end

  
end
