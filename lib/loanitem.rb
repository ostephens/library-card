class Loanitem
    def initialize(id, title, loandate, duedate, renewals, renewable)
        @id = id
        @title = title
        @loandate = loandate
        @duedate = duedate
        @renewals = renewals
        @renewable = renewable
    end
    
    attr_reader :id, :title, :loandate, :duedate, :renewals, :renewable

    def to_s
        "ID: #{@id} Title: #{@title}  #{@authordesc}     Loan date: #{@loandate}   Due date: #{@duedate}   Renewals: #{@renewals}   Renewable? #{renewable}\n"
    end
    
    def printLoanitem
        printed = "ID: #{@id} Title: #{@title}  #{@authordesc}     Loan date: #{@loandate}   Due date: #{@duedate}   Renewals: #{@renewals}   Renewable? #{renewable}<br />"
    end
    
    def htmlLoanitem
        html = "<tr><td>#{@id}</td><td>#{@title}  #{@authordesc}</td><td>#{@loandate}</td><td>#{@duedate.strftime("%d/%m/%Y")}</td><td>#{@renewals}</td><td>#{renewable}</td></tr>"
    end
    
    def printplainLoanitem
        printed = "-----------------------------  Item details  -----------------------------"
        printed += "#{@id}"
        printed += "#{@title}"
        printed += "#{@loandate}"
        printed += "#{@duedate}"
        printed += "#{@renewals}"
        printed += "#{@renewable}"
    end
end