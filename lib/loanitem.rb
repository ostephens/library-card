class Loanitem
    def initialize(id, title, loandate, duedate, renewals)
        @id = id
        @title = title
        @loandate = loandate
        @duedate = duedate
        @renewals = renewals
    end
    
    attr_reader :id, :title, :loandate, :duedate, :renewals

    def to_s
        "ID: #{@id} Title: #{@title}  #{@authordesc}     Loan date: #{@loandate}   Due date: #{@duedate}   Renewals: #{@renewals}\n"
    end
    
    def to_html
        "ID: #{@id} Title: #{@title}  #{@authordesc}     Loan date: #{@loandate}   Due date: #{@duedate}   Renewals: #{@renewals}<br />"
    end
    
    def printLoanitem
        puts "-----------------------------  Item details  -----------------------------"
        puts @id
        puts @title
        puts @loandate
        puts @duedate
    end
end