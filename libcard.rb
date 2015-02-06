require 'rubygems'
require 'sinatra'
require './lib/librarysystems'
require './lib/account'

helpers do
    def loans(libsys, name, bc, pin)
        if (libsys == "warks")
            lib = Warks.new()
        elsif (libsys == "chicago")
            lib = Chicago.new()
        else
            lib = Warks.new()
        end
        ac = Account.new(bc,pin,name,lib)
        ac.getLoans
#        output = ac.printLoans
        output = ac.htmlLoans
        return output
    end
    def renew(name, bc, pin, libsys)
        if (libsys == "warks")
            lib = Warks.new()
        elsif (libsys == "chicago")
            lib = Chicago.new()
        else
            lib = Warks.new()
        end
        ac = Account.new(bc,pin,name,lib)
        ac.getLoans
        ac.renewLoans
#        output = ac.printLoans
        output = ac.htmlLoans
        return output
    end
    def history(name, bc, pin, libsys)
        if (libsys == "warks")
            lib = Warks.new()
        elsif (libsys == "chicago")
            lib = Chicago.new()
        else
            lib = Warks.new()
        end
        ac = Account.new(bc,pin,name,lib)
        ac.getHistory
        output = ac.htmlHistory
        return output
    end
end

get '/' do
    code = "<%= Time.now %>"
    erb code
end

get '/renew/:libsys/:name/:bc/:pin' do
    renew(params[:libsys],params[:name],params[:bc],params[:pin])
end

get '/loans/:libsys/:name/:bc/:pin' do
    loans(params[:libsys],params[:name],params[:bc],params[:pin])
end
