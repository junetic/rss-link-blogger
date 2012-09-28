class EntriesController < ApplicationController
	
	def parse_feed
		@feed = SimpleRSS.parse open('https://groups.google.com/a/ideo.com/group/iad-ny/feed/rss_v2_0_msgs.xml?num=50')
		#@feed = SimpleRSS.parse open('app/assets/images/rss_v2_0_msgs.xml')
		@links = []
		@imgs_and_links = {}
		@link_titles = []
		@imglink = []
		@authors = []

		
		@feed.items.each do |i|

			# Extract URL from <description> in XML and split string to get rid of crap before/after 
			u = URI.extract(i.description)
			u_str = u.to_s
			url = u_str.split("&amp;q=").second.to_s
			url2= url.split("&amp").first.to_s
			# puts "URL2", url2
			
			if url2.include? 'www.ideo.com' 
				url2=""
			elsif url2 == "http://severe-ocean-8569.herokuapp.com"
			 	url2=""
			elsif url2 == "http://checkitcheckitout.com"
			 	url2=""
			else
				if url2.include? 'https' 
					 # url2=url2.sub('https','http')
				end

				@links << url2
				@links.reject! { |e| e.empty? }
				@links = @links.uniq
				# puts "@links", @links
				#temporary substitute links not using feed
				# @links =  ["http://www.buildwithchrome.com/static/map","http://www.buzzfeed.com","http://www.theverge.com/2012/6/24/3114091/sony-xperia-ion-review","http://www.apple.com","http://www.wired.com"]

			end
			# get author & get string between parenthesis
			next if i.title.include? 'Re:'
			auth = i.author
			auth = auth.split("(").second
			auth = auth.sub!(")",'')
			@authors << auth
			
		end
		@linkcount=@links.count
		scrape_links

	end
	def scrape_links
		#debug @links
		@links.each do |link|
			begin
				current_link_imgs = {}
				@imgs_and_links[link] = current_link_imgs
				doc = Nokogiri::HTML(open(link))

			rescue OpenURI::HTTPError
	         	# do something
	         	puts "HTTPError"
	         	 # @imglink <<  "http://schbiolenvsci.files.wordpress.com/2012/02/gex_green-sea-turtle.jpg"
	         	@link_titles << link


	       	rescue OpenSSL::SSL::SSLError
	          	# do something else
	          	puts "OpenSSL Error"
	          	# @imglink <<  "http://schbiolenvsci.files.wordpress.com/2012/02/gex_green-sea-turtle.jpg"
	          	@link_titles << link

	       	else
	       		#Scrape Titles
				puts "SCRAPING TITLES"
	       		linkt = doc.xpath('//title').text
				@link_titles << linkt
	        
				#Scrape Images
				puts "SCRAPING IMAGES"
				doc.xpath("//img").each do |img|
					next if img["src"].blank?
					next if img["src"].length > 150
					image = URI.escape(img["src"].strip)
					if image.include? 'https' 
						image=image.sub('https','http')
					elsif image.exclude? 'http'
						# make into absolute url
						image = URI.parse(link).merge(URI.parse image.to_s).to_s
						 # puts image
					end
					# final hash looks like..{link => {"img_url"=> 0}}
					current_link_imgs[image] = 0
				end
				# puts "current_link_imgs",current_link_imgs
			end
		end

		get_largest_image @imgs_and_links
	end

	def get_largest_image links_to_image_hash
		puts "GETTING LARGEST IMAGE"

		links_to_image_hash.each do |link, image_hash|

			  # iterate through every image url, compute the size and store it under the img url
			  max = 0
			  @max_img_url = nil
			  # puts "IMGURL", image_hash.keys
			  image_hash.keys.each do |img_url|
			  	
			  	size = FastImage.size(img_url)
				unless size.nil?
					width = size[0]
					height = size[1]
					
				  	size_area_val = (width*height)/100
				  	image_hash[img_url] = size_area_val 
				  	if size_area_val > max
				  		max = size_area_val
				  		if height >100
				  			@max_img_url = img_url
				  		else
				  			@max_img_url = "http://schbiolenvsci.files.wordpress.com/2012/02/gex_green-sea-turtle.jpg"
				  		end
				  	end

			  	end
			  	
			  end

			  @imglink << @max_img_url
			  puts "LARGEST IMAGE IS", @max_img_url
			  

		end
		save_scraped_data
	end

	def save_scraped_data
		# Entry.destroy_all
		0.upto(@linkcount-1)  do |i|
			e = Entry.find_or_create_by_link_and_title_and_author(:link =>@links[i], :title => @link_titles[i], :author => @authors[i])
			e.imgurl = @imglink[i]
			e.save

		end
	end
end
