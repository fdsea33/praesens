
class ::Date

  def end_of_month
    dd  = ::Time.new.beginning_of_day.change :year=>self.year, :month=>self.month, :mday=>self.mday
    day = dd.end_of_month
    Date.civil(day.year,day.month,day.mday)
  end

  def beginning_of_month
    Date.civil(self.year,self.month,1)
  end

end
