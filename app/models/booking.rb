class Booking < ActiveRecord::Base
	belongs_to :guest
	belongs_to :experience
	has_one :testimonial
	has_many :messages
	
	validates :guest_id, :experience_id, :date, presence: true
	validate :group_size_must_not_exceed_maximum

	def group_size_must_not_exceed_maximum
		max = self.experience.max_group_size
		unless (max >= 0 && max == nil)
			if self.group_size > self.experience.max_group_size
				errors.add(:group_size, "cannot exceed maximum (#{max} people)")
			end
		end
	end

	def self.update_status(status)
		case status.downcase
		# when "Requested" #default
		when "invite"
			status.replace("invited")
		when "reject"
			status.replace("rejected")
		when "complete"
			status.replace("completed")
		end
		status
	end

	def self.statuses
		["Invite", "Reject", "Complete"]
	end

	# DO STUFF HERE MON
	serialize :notification_params, Hash
	def paypal_url(return_path)
	@experience = Experience.find(self.experience_id)
	values = {
	    business: "seller@nasi.com",
	    cmd: "_xclick",
	    upload: 1,
	    return: "#{Rails.application.secrets.app_host}#{return_path}",
	    invoice: id,
	    amount: @experience.price,
	    item_name: "#{@experience.title} experience booking",
	    item_number: @experience.id,
	    quantity: self.group_size,
	    notify_url: "#{Rails.application.secrets.app_host}/hook"
	}
	"#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
	end

end
