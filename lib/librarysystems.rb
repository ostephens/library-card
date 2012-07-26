require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'pony'
require './lib/loanitem'
require './lib/loanlist'

class Librarysystem
    #superclass which describes a library system - just a url, as yet no methods
    def initialize(url)
		@url = url
	end	
    attr_reader :url
    attr_accessor :barcode, :pin
end

class Vubis < Librarysystem
    def initialize(url)
        super(url)
        @browser = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
    end
    attr_accessor :browser, :page
    
    def logIn(url,barcode,pin)
        # perhaps should track session - start time
        # then could avoid logging in again if not expired (Warks time seems to be <=10min)
        @page = @browser.get(url)
        @page = @browser.click(@page.frame_with(:name => 'Body'))
        @page = @page.form_with(:name => 'Login') do |form|
            form.CardId = barcode
            form.Pin = pin
        end.submit
    end

    def gotoCurrentloans
        @page = @browser.click(@page.frame_with(:name => 'Body'))
        @page = @browser.click(@page.link_with(:text => /My loans and renewals/))
        borrower_id = @page.parser.xpath("//frame[@name='Body']").attribute("src").to_s.sub(/(.*BorrowerId=)([^&]*)(.*$)/,'\2')
        @page = @browser.click(@page.frame_with(:name => 'Body'))
        return borrower_id
    end

    def scrapeCurrentloans(table)
        l = Loanlist.new()
        table.xpath('table[3]/tr').each do |itemrow|
            if itemrow.xpath('td[1]').attribute("class").to_s == 'listhead'
            else
                id = itemrow.xpath('td[1]/input/@value')
                if (id.length == 0)
                    id = itemrow.xpath('td[3]').inner_text
                    renewable = "No"
                end
                title = itemrow.xpath('td[2]').inner_text.chop.strip
                loan_date = itemrow.xpath('td[5]').inner_text
                renewals = itemrow.xpath('td[7]').inner_text
                if renewals > "2"
                    renewable = "No"
                end
                if renewable != "No"
                    renewable = "Yes"
                end
                due_s = itemrow.xpath('td[6]').inner_text
                due = Date.strptime(due_s, "%d/%m/%Y")
                l.addLoan(Loanitem.new(id, title,loan_date,due,renewals,renewable))
            end
        end
        return l
    end

    def getCurrentloans(barcode, pin)
        #this is where we retrieve current loans and use it to create an array of loanitem objects
        self.logIn(@url + "Pa.csp?OpacLanguage=eng&Profile=Default",barcode,pin)
        self.gotoCurrentloans
        itemtable = @page.parser.xpath('//form/table[3]')
        self.scrapeCurrentloans(itemtable)
    end

    def renewLoans(barcode,pin,loans)
        # check we have some loans

        if (loans.length == 0)
            return false
        end

        # login and renew loans in @currentloans
        self.logIn(@url + "Pa.csp?OpacLanguage=eng&Profile=Default",barcode,pin)
        borrower_id = self.gotoCurrentloans          
        opac_lang = @page.parser.xpath("//form/input[@name='OpacLanguage']").attribute("value").to_s
        profile = @page.parser.xpath("//form/input[@name='Profile']").attribute("value").to_s
        request = @page.parser.xpath("//form/input[@name='EncodedRequest']").attribute("value").to_s
        mod = @page.parser.xpath("//form/input[@name='Module']").attribute("value").to_s

        renew_uri = @url + "PBorrower.csp?OpacLanguage=#{opac_lang}&Profile=#{profile}&EncodedRequest=#{request}&BorrowerId=#{borrower_id}&Module=#{mod}&ModParameter=CurrentLoansStep3&Objects=^"
        i = 0
        loans.loans.each do |loan|
            days = loan.duedate - DateTime.now
            if (loan.renewable == "Yes" && days.to_i < 1)
                renew_uri = renew_uri + loan.id.to_s + "^"
                i += 1
            end
        end
        if (i>0)
            @page = @browser.get(renew_uri)
        end
        itemtable = @page.parser.xpath('//form/table[3]')
        return self.scrapeCurrentloans(itemtable)        
    end
end

class Warks < Vubis
    def initialize()
        super(browser)
        @url = "https://library.warwickshire.gov.uk/vs/"
    end
end

class Tlccarl < Librarysystem
    def initialize(url)
        super(url)
        @browser = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
    end
    attr_accessor :browser, :page
    
    def logIn(url,barcode,pin)
        @page = @browser.get(url)
        @page = @page.form_with(:action => '/mycpl/login/') do |form|
            form.patronId = barcode
            form.zipCode = pin
        end.submit
    end

    def scrapeLoans
        l = Loanlist.new()
        i = 0
        @page.parser.xpath('//table[1]/tr').each do |itemrow|
            i += 1
            next if i == 1
            id = itemrow.xpath('td[1]/input/@value')
            title = itemrow.xpath('td[2]').inner_text.chop.strip
            due_s = itemrow.xpath('td[4]').inner_text
            due = Date.strptime(due_s, "%m/%d/%Y")
            loan_date = ""
            renewals = ""
            renewable = ""
            l.addLoan(Loanitem.new(id, title,loan_date,due,renewals,renewable))
        end
        return l
    end
    
    def gotoSummary
        #this needs to come from chicago, not in Tlccarl
        @page = @browser.get("https://www.chipublib.org/mycpl/summary/")
    end

    def getCurrentloans(barcode, pin)
        #this is where we retrieve current loans and use it to create an array of loanitem objects
        self.logIn(@url,barcode,pin)
        self.gotoSummary
        self.scrapeLoans
    end

    def renewLoans(barcode,pin,loans)
        # check we have some loans

        if (loans.length == 0)
            return false
        end

        # login and renew loans in @currentloan
        i = 0
        loans.loans.each do |loan|
            days = loan.duedate - DateTime.now
            if (loan.renewable == "Yes" && days.to_i < 1)
                renew_uri = renew_uri + loan.id.to_s + "^"
                i += 1
            end
        end
        if (i>0)
            @page = @browser.get(renew_uri)
        end
        itemtable = @page.parser.xpath('//form/table[3]')
        return self.scrapeCurrentloans(itemtable)        
    end
end

class Chicago < Tlccarl
    def initialize()
        super(browser)
        @url = "https://www.chipublib.org/mycpl/login/"
    end
end