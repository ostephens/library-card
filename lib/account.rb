require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'pony'
require './lib/loanitem'
require './lib/loanlist'

class Account
    def initialize(barcode, pin, email, libsys)
        @barcode = barcode
        @pin = pin
        @email = email
        @libsys = libsys
        @currentloans = Loanlist.new()
        @borrower_id
    end
    
    attr_reader :barcode, :pin, :email, :libsys
    attr_accessor :currentloans, :borrower_id
    
    def logIn(agent, url)
        login_page = agent.get(url)
        login_frame = agent.click(login_page.frame_with(:name => 'Body'))
        myaccount_page = login_frame.form_with(:name => 'Login') do |form|
            form.CardId = @barcode
            form.Pin = @pin
        end.submit
        return myaccount_page
    end
    
    def gotoCurrentloans(agent, page)
        current_loans = agent.click(page.frame_with(:name => 'Body'))
        current_loans = agent.click(current_loans.link_with(:text => /My loans and renewals/))
        @borrower_id = current_loans.parser.xpath("//frame[@name='Body']").attribute("src").to_s.sub(/(.*BorrowerId=)([^&]*)(.*$)/,'\2')
        current_loans = agent.click(current_loans.frame_with(:name => 'Body'))
        return current_loans
    end
    
    def scrapeCurrentloans(table)
        l = Loanlist.new()
        table.xpath('table[3]/tr').each do |itemrow|
            if itemrow.xpath('td[1]').attribute("class").to_s == 'listhead'
            else
                id = itemrow.xpath('td[1]/input/@value')
                if (id.length == 0) # if no id in checkbox (e.g. when item already been renewed today)
                     id = itemrow.xpath('td[3]').inner_text #take from barcode cell instead
                end
                title = itemrow.xpath('td[2]').inner_text.chop.strip
                loan_date = itemrow.xpath('td[5]').inner_text
                renewals = itemrow.xpath('td[7]').inner_text
                if renewals === "2"
                    renewals = "2 - Last time you can renew online, take it back!"
                end
                due_s = itemrow.xpath('td[6]').inner_text
                due = Date.strptime(due_s, "%d/%m/%Y")
                # currently pushing all items to list - this is right I think
                # means we need method to test 'dueness' of loan item etc.
                l.addLoan(Loanitem.new(id, title,loan_date,due,renewals))
            end
        end
        return l
    end
    
    def getCurrentloans
        #this is where we retrieve current loans and use it to create an array of loanitem objects
        
        a = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        myaccount_page = self.logIn(a, @libsys.url + "Pa.csp?OpacLanguage=eng&Profile=Default")
        current_loans = self.gotoCurrentloans(a,myaccount_page)
        itemtable = current_loans.parser.xpath('//form/table[3]')
        @currentloans = self.scrapeCurrentloans(itemtable)
    end
    
    def renewLoans
        # check we have some loans

        if (@currentloans.length == 0)
            return false
        end
        
        # login and renew loans in @currentloans
        
        a = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }

        myaccount_page = self.logIn(a, @libsys.url + "Pa.csp?OpacLanguage=eng&Profile=Default")
        current_loans = self.gotoCurrentloans(a,myaccount_page)            
        opac_lang = current_loans.parser.xpath("//form/input[@name='OpacLanguage']").attribute("value").to_s
        profile = current_loans.parser.xpath("//form/input[@name='Profile']").attribute("value").to_s
        request = current_loans.parser.xpath("//form/input[@name='EncodedRequest']").attribute("value").to_s
        mod = current_loans.parser.xpath("//form/input[@name='Module']").attribute("value").to_s
            
        renew_uri = @libsys.url + "PBorrower.csp?OpacLanguage=#{opac_lang}&Profile=#{profile}&EncodedRequest=#{request}&BorrowerId=#{@borrower_id}&Module=#{mod}&ModParameter=CurrentLoansStep3&Objects=^"
        i = 0
        @currentloans.loans.each do |loan|
            days = loan.duedate - DateTime.now
            if (loan.renewals.to_i < 3 && days.to_i < 1)
                renew_uri = renew_uri + loan.id.to_s + "^"
                i += 1
            end
        end
        puts renew_uri
        if (i>0)
            renewal_page = a.get(renew_uri)
            itemtable = renewal_page.parser.xpath('//form/table[3]')
            @currentloans = self.scrapeCurrentloans(itemtable)
        end
    end
    
    def send_email(from)
        Pony.mail(:to => @email, :from => from, :subject => 'Loans due for renewal', :body => @currentloans.printLoanlist)
    end
    
end