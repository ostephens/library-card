require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'date'
require 'pony'
require 'libcard/loanitem'
require 'libcard/loanlist'

class Account
    def initialize(barcode, pin, email, libsys)
        @barcode = barcode
        @pin = pin
        @email = email
        @libsys = libsys
        @currentloans = Loanlist.new()
    end
    
    attr_reader :barcode, :pin, :email, :libsys
    attr_accessor :currentloans
    
    def getCurrentloans
        #this is where we retrieve current loans and use it to create an array of loanitem objects
        
        a = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }

        a.get(@libsys.url) do |login_page|
            login_frame = a.click(login_page.frame_with(:name => 'Body'))
            
            myaccount_page = login_frame.form_with(:name => 'Login') do |form|
                form.CardId = @barcode
                form.Pin = @pin
            end.submit
            
            myaccount_frame = a.click(myaccount_page.frame_with(:name => 'Body'))
            
            loanhistory_page = a.click(myaccount_frame.link_with(:text => /My loans and renewals/))
            
            loanhistory_frame = a.click(loanhistory_page.frame_with(:name => 'Body'))

            itemtable = loanhistory_frame.parser.xpath('//form/table[3]')
            
            itemtable.xpath('table[3]/tr').each do |itemrow|
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
                    @currentloans.addLoan(Loanitem.new(id, title,loan_date,due,renewals))
                end
            end
        end
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

        a.get(@libsys.url) do |login_page|
            login_frame = a.click(login_page.frame_with(:name => 'Body'))
            
            myaccount_page = login_frame.form_with(:name => 'Login') do |form|
                form.CardId = @barcode
                form.Pin = @pin
            end.submit
            
            myaccount_frame = a.click(myaccount_page.frame_with(:name => 'Body'))
            
            loanhistory_page = a.click(myaccount_frame.link_with(:text => /My loans and renewals/))
            borrower_id = loanhistory_page.parser.xpath("//frame[@name='Body']").attribute("src").to_s.sub(/(.*BorrowerId=)([^&]*)(.*$)/,'\2')
            loanhistory_frame = a.click(loanhistory_page.frame_with(:name => 'Body'))
            
            opac_lang = loanhistory_frame.parser.xpath("//form/input[@name='OpacLanguage']").attribute("value").to_s
            profile = loanhistory_frame.parser.xpath("//form/input[@name='Profile']").attribute("value").to_s
            request = loanhistory_frame.parser.xpath("//form/input[@name='EncodedRequest']").attribute("value").to_s
            mod = loanhistory_frame.parser.xpath("//form/input[@name='Module']").attribute("value").to_s
            
            renew_uri = "https://library.warwickshire.gov.uk/vs/PBorrower.csp?OpacLanguage=#{opac_lang}&Profile=#{profile}&EncodedRequest=#{request}&Module=#{mod}&ModParameter=CurrentLoansStep3&Objects=^"
            i = 0
            @currentloans.loans.each do |loan|
                days = loan.duedate - DateTime.now
                # puts "#{loan.id}  #{days.to_i}"
                if (loan.renewals.to_i < 3 && days.to_i < 1)
                    renew_uri = renew_uri + loan.id.to_s + "^"
                    i += 1
                end
#                if (loan.id.to_s == "0134654546")
#                    puts "Going for renew"
#                    renew_uri = renew_uri + loan.id.to_s + "^"
#                end
            end
            # puts renew_uri
            if (i > 0)
                a.get(renew_uri) do |renewal_page|
                    # puts renewal_page.parser.xpath("/").to_s
                end
            end
        end
    end
    
    def send_email(from)
        Pony.mail(:to => @email, :from => from, :subject => 'Loans due for renewal', :body => @currentloans.printLoanlist)
    end
    
end