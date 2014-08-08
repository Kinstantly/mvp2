module RatingsHelper
	def rating_score_stars_css_class(score)
		score ||= 0
		score_int = score.to_i
		score_half = score - score_int >= 0.5 ? 'half' : ''
		"reviewed-#{score_int}#{score_half}-star"
	end
end
