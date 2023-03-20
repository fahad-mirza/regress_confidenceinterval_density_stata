	
	* Scatter with regression line and CI density
	
	* Install commands:
	ssc install palettes, replace
	ssc install colrspace, replace
	ssc install schemepack, replace
	
	
	
	* Loading Stata dataset and running an arbitrary regression
	sysuse auto, clear 

	sort weight, stable

	regress mpg weight 
	predict fit, xb
	predict se, stdp
	
	
	* Looping to form the graph command for each desired observation number in the weight
	* variable
	
	foreach num of numlist 20 30 40 60 70 {
	
		local N = `"weight[`num'] - 500 * normalden(x, fit[`num'], se[`num'])"'
		local NRange = string(`=fit[`num']'-5) + " " + string(`=fit[`num']'+5)

		local M = fit[`num']
		local MRange = string(`=weight[`num']') + " " + string(`=weight[`num'] - 500 * normalden(0, se[`num'])')
		
		local density `density' (function `N', range(`NRange') horizontal lwidth(medium) lpattern(solid) lcolor("255 127 14") recast(area) nodropbase fcolor("255 127 14%20") lwidth(*0.6)) ///
		
		local avgpoint `avgpoint' (function `M', range(`MRange') lcolor("255 127 14") lwidth(medium) lpattern(solid) lwidth(*0.6)) ///
		
	}
	
	* Horizontal Box Plot
	generate ybox = -1
	egen wp25 = pctile(weight), p(25)
	egen wp50 = pctile(weight), p(50)
	egen wp75 = pctile(weight), p(75)
	
	generate wub = wp75 + (3/2 * (wp75 - wp25))
	generate wlb = wp25 - (3/2 * (wp75 - wp25))
	
	* Vertical Box Plot
	generate xbox = -100
	egen mp25 = pctile(mpg), p(25)
	egen mp50 = pctile(mpg), p(50)
	egen mp75 = pctile(mpg), p(75)
	
	generate mub = mp75 + (3/2 * (mp75 - mp25))
	generate mlb = mp25 - (3/2 * (mp75 - mp25))
	
	
	* Putting it all together:
	twoway 	(scatter mpg weight, mcolor(%50) mlwidth(0)) ///
			`density' ///
			`avgpoint' ///
			(line fit weight, lwidth(medium) lpattern(solid) lcolor("23 190 207")) ///
			///
			(rspike wlb wub ybox in 1, horizontal lcolor(black) lwidth(*0.5) msize(medium)) ///
			(rbar wp25 wp75 ybox in 1, horizontal barwidth(1) fcolor(white) lcolor(black) lwidth(*0.5)) ///
			(scatteri `=ybox[1]' `=wp50[1]', mcolor(black) msize(*0.5) msymbol(square)) ///
			(scatter ybox weight if weight < wlb | weight > wub, mcolor(black) msize(*0.5) msymbol(circle)) ///
			///
			(rspike mlb mub xbox in 1, vertical lcolor(black) lwidth(*0.5) msize(medium)) ///
			(rbar mp25 mp75 xbox in 1, vertical barwidth(80) fcolor(white) lcolor(black) lwidth(*0.5)) ///
			(scatteri `=mp50[1]' `=xbox[1]', mcolor(black) msize(*0.5) msymbol(square)) ///
			(scatter mpg xbox if mpg < mlb | mpg > mub, mcolor(black) msize(*0.5) msymbol(circle)) ///			
			, ///
			ytitle("MPG", orient(horizontal) size(2.5)) ///
			ylabel(, nogrid labsize(2)) ///
			yscale(range(0 43)) ///
			xtitle("Weight", size(2.5)) ///
			xlabel(, nogrid labsize(2)) ///
			legend(off) ///
			title("{bf}Scatter with regression line and confidence interval densities", size(3) pos(11)) ///
			scheme(white_tableau)
			
			
	* Exporting the plot		
	graph export "./scatter_regress_CI_density_marginal_boxplot.png", as(png) width(3840) replace
			
	
	