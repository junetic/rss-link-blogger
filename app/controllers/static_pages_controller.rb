class StaticPagesController < ApplicationController
	def home
		@feed = SimpleRSS.parse open('https://groups.google.com/a/ideo.com/group/iad-ny/feed/rss_v2_0_msgs.xml')
		#@feed = SimpleRSS.parse open('app/assets/images/rss_v2_0_msgs.xml')
		@links = []
		@imglink = []
		@imgs_from_link = []
		@imgs_from_all_links = []
		@link_titles = []
		@width = 0

		@feed.items.each do |i|
			#@desc << i.description

			# Extract URL from <description> in XML and split string to get rid of crap before/after 
			u = URI.extract(i.description)
			u_str = u.to_s
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
				#@links << url2
				@links.reject! { |e| e.empty? }
				#temporary substitute links not using feed
				@links =  ["http://www.qbn.com","http://www.boingboing.net", "http://www.fastcodesign.com", "http://www.nytimes.com","http://www.theverge.com"]
			end
		end
		@linkcount=@links.count

		def scrape_links
			#debug @links
			@links.each do |t|
				#Scape Titles
				doc = Nokogiri::HTML(open(t))
				linkt = doc.xpath('//title').text
				@link_titles << linkt

				#Scrape Images
				image_scraper = ImageScraper::Client.new(t)
				@imgs_from_link = image_scraper.image_urls[0..10]

				@imgs_from_all_links << @imgs_from_link
				
			end
		end

		def get_largest_image
			# @size=FastImage.size(@imgs_from_all_links[0][5])
			0.upto(@imgs_from_all_links.count-1)  do |i|
				0.upto(@imgs_from_link.count-1)  do |z|
					@size = FastImage.size(@imgs_from_all_links[i][z])
					@width = @size[0]
					if @width > 200
						@imglink << @imgs_from_all_links[i][z]

					end

				end

			end

		end

		scrape_links
		get_largest_image


	end
	
end
