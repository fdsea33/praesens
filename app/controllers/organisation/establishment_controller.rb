require 'pdf/writer'

class Organisation::EstablishmentController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title = "Listing x".t CompanyEstablishment.localized_model_name
    @company_establishment_pages, @company_establishments = paginate :company_establishments, :per_page => 10, :conditions => ["company_id=?",@current_company_id]
  end

  def show
    @company_establishment = CompanyEstablishment.find(params[:id])
  end

  def pdf
    pdf = PDF::Writer.new(:paper=>PDF::Writer::PAGE_SIZES["A4"], :orientation => :portrait )
    pdf.info.title = "Certificate of Achievement"
    pdf.select_font 'Times-Roman'
    pdf.image 'public/images/praesens.jpg', :justification => :left
    pdf.image 'public/images/praesens.jpg', :justification => :center, :resize=>0.3
    pdf.image 'public/images/praesens.jpg', :justification => :right,  :resize=>0.3
    for x in 1..50
      pdf.text "Hello, Ruby. ".center(300,"Un test avec PDF::Writer qui semble correct. "), :font_size => 12, :justification => x%2==0 ? :justify : :justify
    end
    send_data pdf.render, :filename => 'tutu.pdf', :type => "application/pdf" 
  end


  def fpdf
    pdf=FPDF.new;
    pdf.AddPage();
#    pdf.SetFont('Dominican','B',16);
    pdf.SetFont('Arial','B',16);
    pdf.Cell(40,10,'Hello World !');
    send_data pdf.Output, :filename => "something.pdf", :type => "application/pdf" 
  end

  def new
    @company_establishment = CompanyEstablishment.new
  end

  def create
    params[:company_establishment][:company_id] = @current_company_id
    @company_establishment = CompanyEstablishment.new(params[:company_establishment])
    if @company_establishment.save
      flash[:notice] = 'CompanyEstablishment was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @company_establishment = CompanyEstablishment.find(params[:id])
  end

  def update
    @company_establishment = CompanyEstablishment.find(params[:id])
    if @company_establishment.update_attributes(params[:company_establishment])
      flash[:notice] = 'CompanyEstablishment was successfully updated.'
      redirect_to :action => 'show', :id => @company_establishment
    else
      render :action => 'edit'
    end
  end

  def destroy
    CompanyEstablishment.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
