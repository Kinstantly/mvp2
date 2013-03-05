class Hash
	def values_present?(*keys)
		values_at(*keys).map(&:presence).compact.size == keys.size
	end
end