require 'rubygems'
require 'sinatra'
require './lib/librarysystems'
require './lib/account'

helpers do
    def loans(name, bc, pin)
        warks = Warks.new()
        ac = Account.new(bc,pin,name,warks)
        ac.getLoans
#        output = ac.printLoans
        output = ac.htmlLoans
        return output
    end
    def renew(name, bc, pin)
        warks = Warks.new()
        ac = Account.new(bc,pin,name,warks)
        ac.getLoans
        ac.renewLoans
#        output = ac.printLoans
        output = ac.htmlLoans
        return output
    end
end

get '/' do
    code = "<%= Time.now %>"
    erb code
end

get '/renew/:name/:bc/:pin' do
    renew(params[:name],params[:bc],params[:pin])
end

get '/loans/:name/:bc/:pin' do
    loans(params[:name],params[:bc],params[:pin])
end
