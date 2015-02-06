require 'rubygems'
require 'pony'
require './lib/loanlist'

class Account
    def initialize(barcode, pin, email, libsys)
        @barcode = barcode
        @pin = pin
        @email = email
        @libsys = libsys
        @currentloans = Loanlist.new()
        @borrower_id
        @loanhistory = Loanlist.new()
    end
    
    attr_reader :barcode, :pin, :email, :libsys
    attr_accessor :currentloans, :borrower_id, :loanhistory
    
    def getLoans
        @currentloans = @libsys.getCurrentloans(@barcode, @pin)
    end
    
    def renewLoans
        @currentloans = @libsys.renewLoans(@barcode,@pin,@currentloans)
    end

    def getHistory
        @loanhistory = @libsys.getLoanhistory(@barcode, @pin)
    end

    def send_email(from)
        Pony.mail(:to => @email, :from => from, :subject => 'Loans due for renewal', :body => @currentloans.printLoanlist)
    end
    
    def printLoans
        @currentloans.printLoanlist
    end
    
    def htmlLoans
        @currentloans.htmlLoanlist
    end

    def htmlHistory
        @loanhistory.htmlLoanlist
    end
    
end