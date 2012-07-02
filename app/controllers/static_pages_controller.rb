class StaticPagesController < ApplicationController
	def home
		# @entries = Entry.all
		@entries = Entry.find(:all, :order => "created_at")
	end


end