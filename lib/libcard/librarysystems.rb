class Librarysystem
    #superclass which describes a library system - just a name and url, as yet no methods
    def initialize(name, url)
    	@name = name
		@url = url
	end	
    attr_reader :name, :url
end

class Vubis < Librarysystem
    def initialize(name, url)
        super(name,url)
    end
end