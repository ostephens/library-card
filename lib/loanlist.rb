class Loanlist
   def initialize
       @loans = Array.new
   end
   
   def addLoan(aLoanitem)
       @loans.push(aLoanitem)
       self
   end
   
   def to_s
        @loans.each do |litem|
            litem.to_s
        end
    end
    
    def to_html
        @loans.each do |litem|
            litem.to_html + "<br />"
        end
    end
    
    def length
        @loans.length
    end
    
    def loans
        @loans
    end
end