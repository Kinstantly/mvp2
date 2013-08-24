class Range
	def *(multiplier)
		Range.new self.begin, ((self.end + 1 - self.begin) * multiplier + self.begin - 1)
	end
end
