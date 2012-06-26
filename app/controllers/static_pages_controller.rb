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
		@height = 0
		@size = []

		@feed.items.each do |i|
			#@desc << i.description

			# Extract URL from <description> in XML and split string to get rid of crap before/after 
			u = URI.extract(i.description)
			u_str = u.to_s
			url = u_str.split("&amp;q=").second.to_s
			url2= url.split("&amp").first.to_s

			
			if url2.include? 'www.ideo.com'
			 	url2=""

			# elsif url2.include? 'www.ustream.tv'
			# 	url2=""

			else
				 if url2.include? 'https' 
					url2=url2.sub('https','http')
				 end

				# @links << url2
				@links.reject! { |e| e.empty? }
				@links = @links.uniq
				# puts "LINKS" , @links
				#temporary substitute links not using feed
				@links =  ["http://www.wired.com","http://www.fastcodesign.com","http://www.nytimes.com","http://www.theverge.com/2012/6/24/3114091/sony-xperia-ion-review"]
			
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
				# image_scraper = ImageScraper::Client.new(t, :include_css_images=> true,  :convert_to_absolute_url=> true)
				# # image_scraper = ImageScraper::Client.new(t)
				# @imgs_from_link = image_scraper.image_urls[0..10]
				# puts "imglinks", @imgs_from_link
				# @imgs_from_all_links << @imgs_from_link
				@imgs_from_link = []	
				doc.xpath("//img").each do |img|
					
					next if img["src"].blank?
       				image = URI.escape(img["src"].strip)
       				if image.include? 'https' 
						image=image.sub('https','http')
					end
        			# image = URI.parse(image).merge(URI.parse t.to_s).to_s
        			@imgs_from_link << image
        			@imgs_from_link = @imgs_from_link[0..6]
				end
				@imgs_from_all_links << @imgs_from_link
			
			end

			 	get_largest_image @imgs_from_all_links


		end
		
		def get_largest_image m
			# @imgs_from_all_links = [["http://www.darylhunt.net/storage/2links.jpg?__SQUARESPACE_CACHEVERSION=1290682400495","http://images4.wikia.nocookie.net/__cb20100624200030/zelda/images/9/9d/Link_Artwork_1_(Twilight_Princess).png"],["http://1.bp.blogspot.com/_i0oWqaDvHK4/TKY5Z3npauI/AAAAAAAAABg/inVCuivT8vg/s1600/Links+Image.gif","http://4.bp.blogspot.com/-t340iHddQbc/TkBE8iCDfJI/AAAAAAAAAEA/DSCU66P5CwU/s1600/mail.jpeg"],["http://www.darylhunt.net/storage/2links.jpg?__SQUARESPACE_CACHEVERSION=1290682400495","http://images4.wikia.nocookie.net/__cb20100624200030/zelda/images/9/9d/Link_Artwork_1_(Twilight_Princess).png"],["http://1.bp.blogspot.com/_i0oWqaDvHK4/TKY5Z3npauI/AAAAAAAAABg/inVCuivT8vg/s1600/Links+Image.gif","http://4.bp.blogspot.com/-t340iHddQbc/TkBE8iCDfJI/AAAAAAAAAEA/DSCU66P5CwU/s1600/mail.jpeg"]]
			m.each do |i|
				i.each do |z|
					
					@size = FastImage.size(z)
					unless @size.nil? 
						# puts "SIZE", @size[0]
						@width = @size[0]
						@height = @size[1]
					
						if @width > 10 and @height >10
							large_img_found = true
							@imglink << z
							break
						#if loop is finishing with no large images, put a turtle on it
						# elsif count>5 and large_img_found == false
						# 	puts "TURTTTTTTTTTTTTTTLE"
						# 	@imglink << "http://schbiolenvsci.files.wordpress.com/2012/02/gex_green-sea-turtle.jpg"
						# 	break
						end		
					end
				
				end
			end
		end
		scrape_links
		

	end
	
end
