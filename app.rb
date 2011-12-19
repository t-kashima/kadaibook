require 'rubygems'
require 'sinatra'
require 'haml'
require 'book'
require 'kadailibrary'
use Rack::Session::Cookie,
:expire_after => 3600,
:secret => Digest::SHA1.hexdigest(rand.to_s)

ENV['AMAZONRCDIR'] = './'
ENV['AMAZONRCFILE'] = '.amazonrc'

set :haml, {:format => :html5}

before %r{^(?!/login$)} do
  if not login?  then
    redirect '/login'
  end
end

get '/' do
  @book
  @error
  @amazonurl = params[:amazonurl] || ""
  if not @amazonurl.empty? then
    @book = Book.search(@amazonurl) || ""
    if @book.empty? then
      @error = "Not a book"
    elsif Kadai::Library.search(@book[:isbn]).size > 0 then
      @error =  "This library has the book"
    else
      @book[:date] = (@book[:date] =~ /^(\d{4})/ ? $1 : "")
    end
  end
  haml :booksearch
end

post '/' do
  keys = [:isbn, :title, :author, :publisher, :date, :price, :place]
  book = Hash[keys.map {|k|
    [k, params[k]]
  }]
  library = Kadai::Library.new(session[:crid])
  library.request_book(book)
  redirect '/'
end

get '/login' do
  haml :login
end

post '/login' do
  library = Kadai::Library.new
  library.login(params[:id], params[:pass])
  session[:crid] = library.crid
  redirect '/'
end

helpers do
  def login?
    session[:crid].nil? ? false : true
  end
end
