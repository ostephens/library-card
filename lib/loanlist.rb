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
    
    def length
        @loans.length
    end
    
    def loans
        @loans
    end
    
    def printLoanlist
        list = ""
        @loans.each do |litem|
            list += litem.printLoanitem.to_s
        end
        return list
    end
    
    def htmlLoanlist
        table = "<table><tr><th>ID</th><th>Title</th><th>Loan Date</th><th>Due date</th><th>Number of renewals</th><th>Renewable?</th>"
        @loans.each do |litem|
            table += litem.htmlLoanitem.to_s
        end
        return table
    end
end