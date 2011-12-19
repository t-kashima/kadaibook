require 'rubygems'
require 'mechanize'
require 'kconv'

class Mechanize::Util
  def self.encode_to(encoding, str)
    if NEW_RUBY_ENCODING
      str.encode(encoding)
    else
      encoding = "sjis" if encoding == "x-sjis"
      Iconv.conv(encoding.to_s, "UTF-8", str)
    end
  end
end

class Kadai
end

class Kadai::Library
  attr_reader :crid
  def initialize(crid = nil)
    @baseurl = 'http://www.lib.kagawa-u.ac.jp'
    @agent = Mechanize.new
    @crid = crid
  end

  def login(id, pass)
    id.downcase!
    id = "s" + id unless /^s/ =~ id
    @agent.get("#{@baseurl}/mylibrary")
    @agent.page.encoding = 'sjis'
    @agent.page.form_with(:action => './'){|form|
      form.set_fields(
                      'username' => id.tosjis,
                      'password' => pass.tosjis
                      )
      form.click_button
    }
    @crid = @agent.page.form_with(:name => 'mylibrary')['crid']
  end

  def request_book(book)
    @agent.get("#{@baseurl}/service/www-bokorder2T-query?CASE=1&IRKBN=0&IRTYPE=2&idkey=#{@crid}")
    @agent.page.form_with(:name => 'ORDER').click_button
    @agent.page.form_with(:name => 'form'){|form|
      form.set_fields(
                      'ISBN'    => book[:isbn],
                      'TR'      => book[:title],
                      'AL'      => book[:author],
                      'PUB'     => book[:publisher],
                      'PYEAR'   => book[:date],
                      'PLANPRI' => book[:price],
                      'DMDMEMO' => book[:place]
                      )
      form.click_button
    }
    @agent.page.form_with(:name => 'form').click_button
  end

  def lending_books
    @agent.get("#{@baseurl}/service/request-query?idkey=#{@crid}")
    @agent.page.content
  end

  def self.search(keyword, univ = false)
    agent = Mechanize.new
    baseurl = 'http://www.lib.kagawa-u.ac.jp'
    if univ then
      agent.get("#{baseurl}/opac/basic-query?mode=2")
    else
      agent.get("#{baseurl}/opac/basic-query")
    end
    agent.page.form_with(:name => 'basic'){|form|
      form['kywd'] = keyword
      form.click_button
    }
    array = Array.new
    if agent.page.form('disp') then
      agent.page.form_with(:name => 'disp'){|form|
        form.page.search('table td[align="left"]').map{|td|
          array.push(td.text)
        }
      }
    end
    array
  end
end

