
class ::String

  def soundex2
    word = self.dup
    steps = ":"#+word+"/"
    word = word.strip.downcase
    word.delete!("\\ -_&|,.!?%$*+=()[]{}#")
    word.tr!("^bcdfghjklmnpqrstvwxz","a")
    steps += word +" / "
#    word.gsub!(/gui/,"ki")
#    word.gsub!(/gue/,"ke")
    word.gsub!(/ga/,"ka")
#    word.gsub!(/go/,"ko")
    word.gsub!(/gu/,"k")
    word.gsub!(/ca/,"ka")
#    word.gsub!(/co/,"ko")
#    word.gsub!(/cu/,"ku")
    word.gsub!(/q/,"k")
    word.gsub!(/cc/,"k")
    word.gsub!(/ck/,"k")
    steps += word +" / "
    word.tr!("eiou","a") if word[0]!="a"
    steps += word +" / "
    word.gsub!(/mac/,"mcc")
    word.gsub!(/asa/,"aza")
    word.gsub!(/kn/,"nn")
    word.gsub!(/pf/,"ff")
    word.gsub!(/sch/,"sss")
    word.gsub!(/ph/,"ff")
    steps += word +" / "
    word.gsub!(/ch/,"ç")
    word.gsub!(/sh/,"@")
    word.delete!("h")
    word.gsub!(/ç/,"ch")
    word.gsub!(/@/,"sh")
    steps += word +" / "
#    word.gsub!(/ay/,"ç")
#    word.delete!("h")
#    word.gsub!(/ç/,"ay")
    steps += word +" / "
    word.gsub!(/[atds]$/,"")
    steps += word +" / "
    word[0]="@" if word[0]=="a"
    word.gsub!(/a/,"")
    word.gsub!(/@/,"a")
    steps += word +" / "
    word.squeeze!
    steps += word +" / "
    word[0..3].strip.upcase.ljust(4," ")#+":: "+steps.dump
  end

  
end
