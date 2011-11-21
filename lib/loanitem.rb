class Loanitem
    def initialize(id, title, loandate, duedate, renewals)
        @id = id
        @title = title
        @loandate = loandate
        @duedate = duedate
        @renewals = renewals
    end
    
    attr_reader :id, :title, :loandate, :duedate, :renewals, :renewable

    def to_s
        "ID: #{@id} Title: #{@title}  #{@authordesc}     Loan date: #{@loandate}   Due date: #{@duedate}   Renewals: #{@renewals}   Renewable? :#{renewable}\n"
    end
    
    def printLoanitem
        puts "-----------------------------  Item details  -----------------------------"
        puts @id
        puts @title
        puts @loandate
        puts @duedate
        puts @renewals
        puts @renewable
    end
end