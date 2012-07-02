class StaticPagesController < ApplicationController
	def home
		@entries = Entry.all
	end


end