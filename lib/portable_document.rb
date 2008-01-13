# New Class PortableDocument based on RFPDF based on FPDF
# Use Ruby convention and add some new helpers

class PortableDocument < FPDF

  alias_method :set_margins         , :SetMargins
  alias_method :set_left_margin     , :SetLeftMargin
  alias_method :set_top_margin      , :SetTopMargin
  alias_method :set_right_margin    , :SetRightMargin
  alias_method :set_auto_page_break , :SetAutoPageBreak
  alias_method :set_display_mode    , :SetDisplayMode
  alias_method :set_compression     , :SetCompression
  alias_method :set_title           , :SetTitle
  alias_method :set_subject         , :SetSubject
  alias_method :set_author          , :SetAuthor
  alias_method :set_keywords        , :SetKeywords
  alias_method :set_creator         , :SetCreator
  alias_method :set_draw_color      , :SetDrawColor
  alias_method :set_fill_color      , :SetFillColor
  alias_method :set_text_color      , :SetTextColor
  alias_method :set_line_width      , :SetLineWidth
  alias_method :set_font            , :SetFont
  alias_method :set_font_size       , :SetFontSize
  alias_method :set_link            , :SetLink
  alias_method :set_xy              , :SetXY
  alias_method :get_string_width    , :GetStringWidth
  alias_method :get_x               , :GetX
  alias_method :set_x               , :SetX
  alias_method :get_y               , :GetY
  alias_method :set_y               , :SetY

  def accept_page_break; @AutoPageBreak; end
  def AcceptPageBreak; accept_page_break; end
  alias_method :add_font            , :AddFont
  alias_method :add_link            , :AddLink
  alias_method :add_page            , :AddPage
  alias_method :alias_nb_pages      , :AliasNbPages
  alias_method :cell                , :Cell
  alias_method :close               , :Close
  alias_method :error               , :Error
  def footer; end
  def Footer; self.footer; end
  def header; end
  def Header; self.header; end
  alias_method :image               , :Image
  alias_method :line                , :Line
  alias_method :link                , :Link
  alias_method :ln                  , :Ln
  alias_method :multi_cell          , :MultiCell
  alias_method :open                , :Open
#  alias_method :Open                , :open
  alias_method :render              , :Output
  alias_method :page_no             , :PageNo
  alias_method :rect                , :Rect
  alias_method :text                , :Text
  alias_method :write               , :Write
  
  
  def initialize(orientation='P', unit='mm', format='A4')
    super(orientation,unit,format)
    @created_at = ::Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end
  
  def table(header=[],data=[], w=[40,35,45,40])
    self.set_fill_color(255,224,192)
    self.set_text_color(32)
d    self.set_draw_color(128,0,0)
    self.set_line_width(0.1)
    self.set_font('','B')
    s=0
    w.each{|x| s = s+x}
    for i in 0..header.size-1
      self.cell(w[i],5,header[i],1,0,'C',1)
    end
    self.ln

    self.set_fill_color(224,235,255)
    self.set_text_color(0)
    self.set_font('')

    fill=0
    for row in data
      self.cell(w[0],4,row[0],'LR',0,'L',fill)
      self.cell(w[1],4,row[1],'LR',0,'L',fill)
      self.cell(w[2],4,row[2],'LR',0,'R',fill)
      self.cell(w[3],4,row[3],'LR',0,'R',fill)
      self.ln
      fill= fill==0 ? 1 : 0
    end
    self.cell(s,0,'','T')
  end
  
  def sub_write(h, txt, link='',sub_font_size=12, sub_offset=0)
    sub_font_size_old = @FontSizePt
    self.set_font_size(sub_font_size)
    sub_offset = (((sub_font_size - sub_font_size_old) / @k) * 0.3) + (sub_offset / @k)
    sub_x        = @x
    sub_y        = @y
    self.set_xy(sub_x, sub_y - sub_offset)
    self.write(h, txt, link)
    sub_x        = @x
    sub_y        = @y
    self.set_xy(sub_x,  sub_y + sub_offset)
    self.set_font_size(sub_font_size_old);
  end
    
end


