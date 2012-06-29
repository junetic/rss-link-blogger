class StaticPagesController < ApplicationController
	def home
		@feed = SimpleRSS.parse open('https://groups.google.com/a/ideo.com/group/iad-ny/feed/rss_v2_0_msgs.xml')
		#@feed = SimpleRSS.parse open('app/assets/images/rss_v2_0_msgs.xml')
		@links = []
		@imgs= {}
		@imgs_and_links = {}
		@link_titles = []
		@imglink = []

		@width = 0
		@height = 0
		@size = []
		@size_hash = {}
		
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

				@links << url2
				@links.reject! { |e| e.empty? }
				@links = @links.uniq
				# puts "LINKS" , @links
				#temporary substitute links not using feed
				# @links =  ["http://www.buildwithchrome.com/static/map","http://www.buzzfeed.com","http://www.theverge.com/2012/6/24/3114091/sony-xperia-ion-review","http://www.apple.com","http://www.wired.com"]
			
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
				doc.xpath("//img").each do |img|
					next if img["src"].blank?
       				image = URI.escape(img["src"].strip)
       				if image.include? 'https' 
						image=image.sub('https','http')

					elsif image.exclude? 'http'
						# make into absolute url
						 image = URI.parse(t).merge(URI.parse image.to_s).to_s
						 # puts image
					end
        			# final hash looks like..{link => {"img_url"=> 0}}
        			@imgs[image]=0
        			@imgs = Hash[@imgs.sort_by{|k,v| -v}[0..6]]
					@imgs_and_links[t] = @imgs
					# puts "@imgs_and_links", @imgs_and_links
					# puts "@imgs", @imgs
				
				end

				
			
			end

			 	 get_largest_image @imgs_and_links
	
		end
		
		def get_largest_image m

			m.each do |k,v|
				v.each do |i,s|

					@size = FastImage.size(i)
					unless @size.nil? 
						@width = @size[0]
						v[i] = @width

						# if z == v.last
							largest_image = v.values.max
							puts "v",v
							# puts " @size_hash", @size_hash
							@imglink << largest_image
							# break
					 	# end
					else
						# @imglink << "http://schbiolenvsci.files.wordpress.com/2012/02/gex_green-sea-turtle.jpg"
						# break
					
					end
				
				end
			end
			puts "@imgs_and_links", @imgs_and_links
		end
		scrape_links
		

	end
	
end
