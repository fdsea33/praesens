class Accountancy::AccountsController < ApplicationController

  auto_complete_belongs_to_for :account, :entity, :full_name
  auto_complete_belongs_to_for :account, :parent, :number

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
#    @title = "Listing x".t Account.localized_model_name
    @account_pages, @accounts = paginate :accounts, :per_page => 30, :order=>:number, :conditions => ["company_id=?",@current_company_id]
  end

  def show
    @account = Account.find_by_id_and_company_id(params[:id], @current_company_id)
    redirect_to :action=>:list if @account.nil?
    @financialyear = Financialyear.find_by_id_and_company_id(params[:year], @account.company_id)
    @financialyear = @account.company.current_financialyear if @financialyear.nil?
    if @financialyear
      @next_year = @financialyear.next_year
      @prev_year = @financialyear.previous_year
    end
    @entries = @account.all_entries(["financialyear_id=?",@financialyear], :id)
    @next_account  = @account.next_neighbour
    @prev_account  = @account.previous_neighbour
    @title = @account.label
  end

  def search
    if request.post?
      params[:search][:company_id] = @current_company_id
      params[:search][:clue] = '%'+params[:search][:clue].strip.tr(" ","%")+'%'
      @account_pages, @accounts = paginate :accounts, :per_page => 30, :conditions => ["company_id=:company_id AND (number LIKE :clue OR name LIKE :clue OR alpha LIKE :clue)", params[:search]], :order=>:number
      if @accounts.size==1
        params[:id] =  @accounts[0].id
        redirect_to :action =>:show, :id=>@accounts[0].id
      else
        render :action => 'list'
      end
    end
  end
  
  def letter
    @account = Account.find(params[:id])
    if request.post?
#      flash[:notice] = params[:entry].keys.to_sentence+ " &bull; "+params[:entry].values.to_sentence+ " &bull; "
      if params[:entry]
        entries_to_letter=[]
        for e in 0..params[:entry].keys.size-1
          entries_to_letter << params[:entry].keys[e] if params[:entry].values[e][:to_letter]=="1"
        end
        begin
          @account.letter(entries_to_letter)
        rescue Exception => exc
          flash.now[:error] = exc.message.t
        end
      end
    end
    @entries = @account.letterable_entries
    if @entries.size<=0
      flash[:notice] = "There is no entries to letter".t
    end
  end
  
  def unletter
    @account = Account.find(params[:id])
    if request.post?
      if params[:entry]
        entries_to_letter=[]
        for e in 0..params[:entry].keys.size-1
          entries_to_letter << params[:entry].keys[e] if params[:entry].values[e][:to_letter]=="1"
        end
        @account.unletter(entries_to_letter)
      end
    end
    @entries = @account.letterable_entries
    render :action=>:letter
    if @entries.size<=0
      flash[:notice] = "There is no entries to unletter".t
    end
  end
  
  def check
  end
  
  
  def curr(x)
    c = Iconv.new 'ISO8859-15', 'UTF-8'
    x==0 ? '' : c.iconv(sprintf("%16.2f",x).strip)
  end

    class ::PortableDocument
      def footer
        c = Iconv.new 'ISO8859-15', 'UTF-8'
        self.set_font('Times','',8)
        self.set_text_color(32)
        self.cell(30, 12,c.iconv(@created_at),0,0,'L')
        self.cell(130,12,c.iconv(@title),0,0,'C')
        self.cell(30, 12,self.page_no.to_s+"/"+self.alias_nb_pages,0,0,'R')
        self.ln
        ActionController::Base.logger.error("Footer")
      end
    end

  
  def print_balance
    if request.post?
#      flash[:notice] = params.keys.to_sentence+" &bull; "+ params.values.collect{|x| if x.is_a?(Array); x.to_sentence; else; x.to_s; end;}.to_sentence
#      return
      balance = {}
      if params[:balance][:period] == "dates"
        balance = @current_company.balance(params[:balance][:started_on],params[:balance][:stopped_on])
        title = "Balance from x to y".t(params[:balance][:started_on],params[:balance][:stopped_on])
      else
        financialyear_id = params[:balance][:financialyear_id]
        financialyear = Financialyear.find_by_id_and_company_id(financialyear_id, @current_company_id)
        balance = financialyear.balance
        if financialyear.closed
          title = "Balance of the year x".t(financialyear.code)
        else
          title = "Temporary balance of the year x".t(financialyear.code)
        end
      end
      if balance.nil?
        flash[:error] = "Balance! #{params[:balance][:period]}, #{params[:balance][:started_on].nil?.to_s}"
      else
#        flash[:error] = "Balance! #{balance.to_s}"
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
      header = ['Compte','Libellé','Débit','Crédit','Débit','Crédit']
      w=[28,80,20,20,20,20]
      pdf.set_fill_color(32)
      pdf.set_text_color(255)
      pdf.set_draw_color(32)
      pdf.set_line_width(0.1)
      pdf.set_font('','B')
      s=0
      pdf.cell(w[0]+w[1],4,'',0,0,'C',0)
      pdf.cell(w[2]+w[3],4,c.iconv('Cumul'),1,0,'C',1)
      pdf.cell(w[4]+w[5],4,c.iconv('Solde'),1,0,'C',1)
      pdf.ln
      w.each{|x| s = s+x}
      for i in 0..header.size-1
        pdf.cell(w[i],4,c.iconv(header[i]),1,0,'C',1)
      end
      pdf.ln

      breaks = []
      for level in 1..64
        v = params[:balance][("break_"+level.to_s).to_sym] 
        break unless v
        breaks[level-1] = (v=="1" ? true : false)
      end

      pdf.set_fill_color(224,235,255)
      pdf.set_text_color(0)
      pdf.set_font('')
#      pdf.set_text_color(0)
#      pdf.set_font('')

      fill=1
      fill = 0
      pdf.set_fill_color(255,255,255)
      accounts = @current_company.accounts.find(:all, :conditions=>["number between ? and ?",params[:balance][:from_account],params[:balance][:to_account]], :order=>:number)
      last = accounts[0].number
      last_account = accounts.size-1
      nb_breaks = breaks.size-1
      total = {"global_debit"=>0.0.to_d, "global_credit"=>0.0.to_d}
      for i in 0..last_account
        account = accounts[i]
        ab = balance[account.number.to_s]
        total["global_debit"]  += ab["local_debit"]||0
        total["global_credit"] += ab["local_credit"]||0
        # Accounts
        if params[:balance][:break_accounts]=="1"
          pdf.cell(w[0],4,account.number,'LRTB',0,'L',1)
          pdf.cell(w[1],4,c.iconv(account.name),'LRTB',0,'L',1)
          pdf.cell(w[2],4,curr(ab["local_debit"]),'LRTB',0,'R',1)
          pdf.cell(w[3],4,curr(ab["local_credit"]),'LRTB',0,'R',1)
          bal = (ab["local_debit"]-ab["local_credit"])||0
          pdf.cell(w[4],4,bal>0 ? curr(bal) : '','LRTB',0,'R',1)
          pdf.cell(w[5],4,bal<0 ? curr(0-bal) : '','LRTB',0,'R',1)
          pdf.ln
        end

        # Total
        next_account = i!=last_account ? accounts[i+1].number : '*'
        nb_breaks.downto(0) do |b|
          if breaks[b]
            if !account.number[b].nil? and next_account[b]!=account.number[b]
              account = @current_company.accounts.find_by_number(account.number[0..b])
              if account
                # sub total
                pdf.set_fill_color(224,235,255)
                pdf.set_font('','B')
                pdf.cell(w[0],4,c.iconv('['+account.number+']'),'LRTB',0,'L',1)
                pdf.cell(w[1],4,c.iconv(account.name),'LRTB',0,'L',1)
                ab = balance[account.number.to_s]
                pdf.cell(w[2],4,curr(ab["global_debit"]),'LRTB',0,'R',1)
                pdf.cell(w[3],4,curr(ab["global_credit"]),'LRTB',0,'R',1)
                bal = (ab["global_debit"]-ab["global_credit"])||0
                pdf.cell(w[4],4,bal>0 ? curr(bal) : '','LRTB',0,'R',1)
                pdf.cell(w[5],4,bal<0 ? curr(0-bal) : '','LRTB',0,'R',1)
                pdf.ln
                pdf.set_fill_color(255,255,255)
                pdf.set_font('','')
              end
            end
          end
        end

        last = account.number
      end
      pdf.cell(s,2,'','T')
      pdf.ln
      pdf.set_fill_color(200,225,255)
      pdf.set_font('','B',10)
      pdf.cell(w[0]+w[1],6,c.iconv('Total'.t),'LRTB',0,'L',1)
#      ab = balance["*"]
      ab = total
      pdf.cell(w[2],6,curr(ab["global_debit"]),'LRTB',0,'R',1)
      pdf.cell(w[3],6,curr(ab["global_credit"]),'LRTB',0,'R',1)
      bal = (ab["global_debit"]-ab["global_credit"])||0
      pdf.cell(w[4],6,bal>0 ? curr(bal) : '','LRTB',0,'R',1)
      pdf.cell(w[5],6,bal<0 ? curr(0-bal) : '','LRTB',0,'R',1)
      pdf.ln
      
      send_data pdf.render, :filename => 'balance.pdf', :type => "application/pdf"
    else
      if @current_company.current_financialyear
        @started_on = @current_company.current_financialyear.started_on
        @stopped_on = Date.today
      else
        @started_on = ""
        @stopped_on = ""
      end
    end
  end







  def print_book
    if request.post?
      balance = {}
      if params[:book][:period] == "dates"
        balance = @current_company.balance(params[:book][:started_on],params[:book][:stopped_on])
        title = "Book from x to y".t(params[:book][:started_on],params[:book][:stopped_on])
      else
        financialyear_id = params[:book][:financialyear_id]
        financialyear = Financialyear.find_by_id_and_company_id(financialyear_id, @current_company_id)
        balance = financialyear.balance
        if financialyear.closed
          title = "Book of the year x".t(financialyear.code)
        else
          title = "Temporary book of the year x".t(financialyear.code)
        end
      end
      if balance.nil?
        flash[:error] = "balance! #{params[:book][:period]}, #{params[:book][:started_on].nil?.to_s}"
      else
#        flash[:error] = "balance! #{book.to_s}"
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
      header = ['Date','Libellé','N°Pièce','J.','Débit','Crédit']
      w=[20,98,18,12,20,20]
      pdf.set_fill_color(32)
      pdf.set_text_color(255)
      pdf.set_draw_color(32)
      pdf.set_line_width(0.1)
      pdf.set_font('','B')
      s=0
      w.each{|x| s = s+x}

      pdf.set_fill_color(224,235,255)
      pdf.set_text_color(0)
      pdf.set_font('')
#      pdf.set_text_color(0)
#      pdf.set_font('')

      fill=1
      fill = 0
      pdf.set_fill_color(255,255,255)
      accounts = @current_company.accounts.find(:all, :conditions=>["number between ? and ?",params[:book][:from_account],params[:book][:to_account]], :order=>:number)
      last_account = accounts.size-1
      nb_columns = header.size-1
      for current_account in 0..last_account
        account = accounts[current_account]
        entries = account.all_entries(["journal_records.created_on BETWEEN ? AND ?",params[:book][:started_on],params[:book][:stopped_on]],"journal_records.created_on, journal_records.journal_id, journal_records.number")
        if params[:book][:print_empty_accounts]=="1" or entries.size>0
          pdf.set_font('Arial','B',12);
          pdf.cell(40,12,c.iconv(account.number),0,0,'L');
          pdf.cell(150,12,c.iconv(account.name),0,1,'L');
        
          if entries.size==0
            pdf.set_fill_color(255)
            pdf.set_text_color(0)
            pdf.set_font('Times','I',8);
            pdf.cell(190,5,c.iconv("No entries".t),0,1,'L');
            pdf.ln
          else
            # Header
            pdf.set_font('Times','B',8);
            pdf.set_fill_color(32)
            pdf.set_text_color(255)
            for i in 0..nb_columns
              pdf.cell(w[i],4,c.iconv(header[i]),1,0,'C',1)
            end
            pdf.ln
            
            # Accounts
            pdf.set_fill_color(255)
            pdf.set_text_color(0)
            pdf.set_font('Times','',8)
            total = {"global_debit"=>0.0.to_d, "global_credit"=>0.0.to_d}
            for entry in entries
              pdf.cell(w[0],4,c.iconv(entry.record.created_on.to_formatted_s(:default)),'LRTB',0,'C',1)
              pdf.cell(w[1],4,c.iconv(entry.name),'LRTB',0,'L',1)
              pdf.cell(w[2],4,c.iconv(entry.record.number.to_s),'LRTB',0,'C',1)
              pdf.cell(w[3],4,c.iconv(entry.record.journal.code),'LRTB',0,'C',1)
              pdf.cell(w[4],4,curr(entry.debit),'LRTB',0,'R',1)
              pdf.cell(w[5],4,curr(entry.credit),'LRTB',0,'R',1)
              pdf.ln
              total["global_debit"]  += entry.debit
              total["global_credit"] += entry.credit
            end
            pdf.cell(s,1,'','T')
            pdf.ln
            pdf.set_fill_color(200,225,255)
            pdf.set_font('','B')
            pdf.cell(w[0]+w[1]+w[2]+w[3],4,c.iconv('Total'.t),'LRTB',0,'L',1)
#           ab = balance["*"]
            ab = total
            pdf.cell(w[4],4,curr(ab["global_debit"]),'LRTB',0,'R',1)
            pdf.cell(w[5],4,curr(ab["global_credit"]),'LRTB',0,'R',1)
#            bal = (ab["global_debit"]-ab["global_credit"])||0
#            pdf.cell(w[4],6,bal>0 ? curr(bal) : '','LRTB',0,'R',1)
#            pdf.cell(w[5],6,bal<0 ? curr(0-bal) : '','LRTB',0,'R',1)
            pdf.ln

          end
#          pdf.cell(s,0,'','T')
#          pdf.ln
          if params[:book][:break_page]=="1" and current_account!=last_account# and balance[accounts[current_account+1].number]["local_count"]>0
            pdf.add_page
          end
        end
        
        
      end
      send_data pdf.render, :filename => 'book.pdf', :type => "application/pdf"
    else

    end
  end











  def print_accounts_list
    @levels = []
    1.upto(16) {|p| @levels<<["Level x".t(p.to_s), p] }
    if request.post?
      title = "Accounting system".t
      depth = params[:accounts_list][:depth].to_i
      if params[:accounts_list][:interval] == "all"
        accounts = @current_company.accounts.find(:all, :conditions=>["number!='*' AND LENGTH(number)<=?", depth], :order=>:number)
      else
        accounts = @current_company.accounts.find(:all, :conditions=>["number!='*' AND LENGTH(number)<=? AND number between ? and ?",depth,params[:accounts_list][:from_account],params[:accounts_list][:to_account]], :order=>:number)
      end
      c = Iconv.new 'ISO8859-15', 'UTF-8'
      pdf = PortableDocument.new;
      pdf.set_title(title)
      pdf.set_subject(title)
      pdf.set_keywords(title)
      pdf.set_creator('Praesens')
      pdf.add_page();
      pdf.set_font('Arial','B',16)
      pdf.cell(190,4,'',0,1,'C')
      pdf.cell(190,12,c.iconv(title),0,1,'C')
      pdf.cell(190,6,'',0,1,'C')
      pdf.set_font('Times','',8)
      header = ['Numéro','Libellé']
      w=[28,160]
      pdf.set_line_width(0.1)
      s=0

      pdf.set_fill_color(224,235,255)
      pdf.set_text_color(0)
      pdf.set_font('')

      pdf.set_fill_color(255,255,255)
      last_account = accounts.size-1
      nb_columns = header.size-1
      for current_account in 0..last_account
        account = accounts[current_account]

        if account.number.size==1
          if params[:accounts_list][:break_page]=="1" and current_account>0
            pdf.add_page
          end
          if params[:accounts_list][:class_title]=="1"
            pdf.set_font('Arial','B',12)
            pdf.cell(s,5,'')
            pdf.ln
            pdf.cell(s,7,c.iconv("Class x".t(account.number)),0,0,'L',1)
            pdf.ln
          end
        end

          if current_account==0 or (account.number.size==1 and (params[:accounts_list][:break_page]=="1" or params[:accounts_list][:class_title]=="1"))
            pdf.set_fill_color(32)
            pdf.set_text_color(255)
            pdf.set_draw_color(32)
            pdf.set_font('Times','B',8)
            w.each{|x| s = s+x}
            for i in 0..header.size-1
              pdf.cell(w[i],4,c.iconv(header[i]),1,0,'C',1)
            end
            pdf.ln
            pdf.set_fill_color(255,255,255)
            pdf.set_text_color(0)
            pdf.set_font('','')
          end



#        pdf.set_font('Arial','B',8)
        pdf.cell(w[0],4,c.iconv(account.number),'TRBL',0,'L',1)
        pdf.cell(w[1],4,c.iconv(account.name),'TRBL',1,'L',1)
      end
      pdf.cell(s,1,'','T')
      pdf.ln
      send_data pdf.render, :filename => 'accounts.pdf', :type => "application/pdf"
    else

    end
  end














  def new
    @account = Account.new
  end

  def create
    params[:account][:company_id] = @current_company_id
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = 'Account was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def new_subaccount
    @account = Account.new
    @account.parent_id = params[:id]
    @account.number = @account.parent.number
    render :action=>:new
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Account was successfully updated.'
      redirect_to :action => 'show', :id => @account
    else
      render :action => 'edit'
    end
  end

  def destroy
    Account.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  private
  
end
