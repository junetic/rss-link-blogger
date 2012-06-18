class StaticPagesController < ApplicationController
	def home
		@feed = SimpleRSS.parse open('https://groups.google.com/a/ideo.com/group/iad-ny/feed/rss_v2_0_msgs.xml')
		@links = []
		@img_links = []
		@link_titles = []

		@feed.items.each do |i|
			#@desc << i.description

			# Extract URL from <description> in XML and split string to get rid of crap before/after 
			u = URI.extract(i.description)
			u_str = u[0].to_s
			url = u_str.split("&amp;q=").second.to_s
			url2= url.split("&amp").first.to_s

			
			if url2.include? 'www.ideo.com'
				url2=""

			elsif url2.include? 'www.ustream.tv'
				url2=""

			else
				if url2.include? 'https' 
					url2=url2.sub('https','http')
					
				end
				@links << url2
				@links.reject! { |e| e.empty? }
				#@links_count = @links.count
				
			end
		end

		def scrape_links
			#debug @links
			@links.each do |t|
				#Scape Titles
				doc = Nokogiri::HTML(open(t))
				linkt = doc.xpath('//title').text
				@link_titles << linkt

				#Scrape Images
				image_scraper = ImageScraper::Client.new(t)
				@img_links << image_scraper.image_urls[1]
			end
		end

		scrape_links


	end
	
end
