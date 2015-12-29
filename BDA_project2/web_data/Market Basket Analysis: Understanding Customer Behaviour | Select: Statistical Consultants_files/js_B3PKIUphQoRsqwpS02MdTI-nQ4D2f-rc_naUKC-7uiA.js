// $Id: hoverIntent.js,v 1.1 2010/07/19 22:25:16 danprobo Exp $
(function($){
	/* hoverIntent by Brian Cherne */
	$.fn.hoverIntent = function(f,g) {
		// default configuration options
		var cfg = {
			sensitivity: 7,
			interval: 100,
			timeout: 0
		};
		// override configuration options with user supplied object
		cfg = $.extend(cfg, g ? { over: f, out: g } : f );

		// instantiate variables
		// cX, cY = current X and Y position of mouse, updated by mousemove event
		// pX, pY = previous X and Y position of mouse, set by mouseover and polling interval
		var cX, cY, pX, pY;

		// A private function for getting mouse position
		var track = function(ev) {
			cX = ev.pageX;
			cY = ev.pageY;
		};

		// A private function for comparing current and previous mouse position
		var compare = function(ev,ob) {
			ob.hoverIntent_t = clearTimeout(ob.hoverIntent_t);
			// compare mouse positions to see if they've crossed the threshold
			if ( ( Math.abs(pX-cX) + Math.abs(pY-cY) ) < cfg.sensitivity ) {
				$(ob).unbind("mousemove",track);
				// set hoverIntent state to true (so mouseOut can be called)
				ob.hoverIntent_s = 1;
				return cfg.over.apply(ob,[ev]);
			} else {
				// set previous coordinates for next time
				pX = cX; pY = cY;
				// use self-calling timeout, guarantees intervals are spaced out properly (avoids JavaScript timer bugs)
				ob.hoverIntent_t = setTimeout( function(){compare(ev, ob);} , cfg.interval );
			}
		};

		// A private function for delaying the mouseOut function
		var delay = function(ev,ob) {
			ob.hoverIntent_t = clearTimeout(ob.hoverIntent_t);
			ob.hoverIntent_s = 0;
			return cfg.out.apply(ob,[ev]);
		};

		// A private function for handling mouse 'hovering'
		var handleHover = function(e) {
			// next three lines copied from jQuery.hover, ignore children onMouseOver/onMouseOut
			var p = (e.type == "mouseover" ? e.fromElement : e.toElement) || e.relatedTarget;
			while ( p && p != this ) { try { p = p.parentNode; } catch(e) { p = this; } }
			if ( p == this ) { return false; }

			// copy objects to be passed into t (required for event object to be passed in IE)
			var ev = jQuery.extend({},e);
			var ob = this;

			// cancel hoverIntent timer if it exists
			if (ob.hoverIntent_t) { ob.hoverIntent_t = clearTimeout(ob.hoverIntent_t); }

			// else e.type == "onmouseover"
			if (e.type == "mouseover") {
				// set "previous" X and Y position based on initial entry point
				pX = ev.pageX; pY = ev.pageY;
				// update "current" X and Y position based on mousemove
				$(ob).bind("mousemove",track);
				// start polling interval (self-calling timeout) to compare mouse coordinates over time
				if (ob.hoverIntent_s != 1) { ob.hoverIntent_t = setTimeout( function(){compare(ev,ob);} , cfg.interval );}

			// else e.type == "onmouseout"
			} else {
				// unbind expensive mousemove event
				$(ob).unbind("mousemove",track);
				// if hoverIntent state is true, then call the mouseOut function after the specified delay
				if (ob.hoverIntent_s == 1) { ob.hoverIntent_t = setTimeout( function(){delay(ev,ob);} , cfg.timeout );}
			}
		};

		// bind the function to the two event listeners
		return this.mouseover(handleHover).mouseout(handleHover);
	};
	
})(jQuery);;
// $Id: superfish.js,v 1.1.4.1 2010/11/11 13:58:25 danprobo Exp $
/*
 * Superfish v1.4.8 - jQuery menu widget
 * Copyright (c) 2008 Joel Birch
 *
 * Dual licensed under the MIT and GPL licenses:
 * 	http://www.opensource.org/licenses/mit-license.php
 * 	http://www.gnu.org/licenses/gpl.html
 *
 * CHANGELOG: http://users.tpg.com.au/j_birch/plugins/superfish/changelog.txt
 */

 jQuery(document).ready(function($) {
    $("#superfish ul.menu").superfish({ 
            delay:       100,                           
            animation:   {opacity:'show',height:'show'},  
            speed:       'fast',                          
            autoArrows:  true,                           
            dropShadows: true                   
        });
  });

;(function($){
	$.fn.superfish = function(op){

		var sf = $.fn.superfish,
			c = sf.c,
			$arrow = $(['<span class="',c.arrowClass,'"> &#187;</span>'].join('')),
			over = function(){
				var $$ = $(this), menu = getMenu($$);
				clearTimeout(menu.sfTimer);
				$$.showSuperfishUl().siblings().hideSuperfishUl();
			},
			out = function(){
				var $$ = $(this), menu = getMenu($$), o = sf.op;
				clearTimeout(menu.sfTimer);
				menu.sfTimer=setTimeout(function(){
					o.retainPath=($.inArray($$[0],o.$path)>-1);
					$$.hideSuperfishUl();
					if (o.$path.length && $$.parents(['li.',o.hoverClass].join('')).length<1){over.call(o.$path);}
				},o.delay);	
			},
			getMenu = function($menu){
				var menu = $menu.parents(['ul.',c.menuClass,':first'].join(''))[0];
				sf.op = sf.o[menu.serial];
				return menu;
			},
			addArrow = function($a){ $a.addClass(c.anchorClass).append($arrow.clone()); };
			
		return this.each(function() {
			var s = this.serial = sf.o.length;
			var o = $.extend({},sf.defaults,op);
			o.$path = $('li.'+o.pathClass,this).slice(0,o.pathLevels).each(function(){
				$(this).addClass([o.hoverClass,c.bcClass].join(' '))
					.filter('li:has(ul)').removeClass(o.pathClass);
			});
			sf.o[s] = sf.op = o;
			
			$('li:has(ul)',this)[($.fn.hoverIntent && !o.disableHI) ? 'hoverIntent' : 'hover'](over,out).each(function() {
				if (o.autoArrows) addArrow( $('>a:first-child',this) );
			})
			.not('.'+c.bcClass)
				.hideSuperfishUl();
			
			var $a = $('a',this);
			$a.each(function(i){
				var $li = $a.eq(i).parents('li');
				$a.eq(i).focus(function(){over.call($li);}).blur(function(){out.call($li);});
			});
			o.onInit.call(this);
			
		}).each(function() {
			var menuClasses = [c.menuClass];
			if (sf.op.dropShadows  && !($.browser.msie && $.browser.version < 7)) menuClasses.push(c.shadowClass);
			$(this).addClass(menuClasses.join(' '));
		});
	};

	var sf = $.fn.superfish;
	sf.o = [];
	sf.op = {};
	sf.IE7fix = function(){
		var o = sf.op;
		if ($.browser.msie && $.browser.version > 6 && o.dropShadows && o.animation.opacity!=undefined)
			this.toggleClass(sf.c.shadowClass+'-off');
		};
	sf.c = {
		bcClass     : 'sf-breadcrumb',
		menuClass   : 'sf-js-enabled',
		anchorClass : 'sf-with-ul',
		arrowClass  : 'sf-sub-indicator',
		shadowClass : 'sf-shadow'
	};
	sf.defaults = {
		hoverClass	: 'sfHover',
		pathClass	: 'overideThisToUse',
		pathLevels	: 1,
		delay		: 800,
		animation	: {opacity:'show'},
		speed		: 'normal',
		autoArrows	: true,
		dropShadows : true,
		disableHI	: false,		// true disables hoverIntent detection
		onInit		: function(){}, // callback functions
		onBeforeShow: function(){},
		onShow		: function(){},
		onHide		: function(){}
	};
	$.fn.extend({
		hideSuperfishUl : function(){
			var o = sf.op,
				not = (o.retainPath===true) ? o.$path : '';
			o.retainPath = false;
			var $ul = $(['li.',o.hoverClass].join(''),this).add(this).not(not).removeClass(o.hoverClass)
					.find('>ul').hide().css('visibility','hidden');
			o.onHide.call($ul);
			return this;
		},
		showSuperfishUl : function(){
			var o = sf.op,
				sh = sf.c.shadowClass+'-off',
				$ul = this.addClass(o.hoverClass)
					.find('>ul:hidden').css('visibility','visible');
			sf.IE7fix.call($ul);
			o.onBeforeShow.call($ul);
			$ul.animate(o.animation,o.speed,function(){ sf.IE7fix.call($ul); o.onShow.call($ul); });
			return this;
		}
	});

})(jQuery);
;
/**
*
* Copyright Rob Schmitt
* form-default-value.js
*
* This script searches the current page for all form input fields
* that have a 'default-value' class applied. The script then changes
* the color of whatever default text has been provided to the value
* of 'inactive_color'. If the user clicks on the input field, the
* default text is blanked, and the color changed to 'active_color'.
* If the user clicks away from the input field, the script will revert
* back to the default text (changing the color back to 'inactive_color',
* unless the user has entered some text.
*/

/**
* The following variables may be adjusted
*/
var active_color = '#000'; // Color of user provided text
var inactive_color = '#ccc'; // Color of default text

/**
* Do not modify anything below this line
*/

if (Drupal.jsEnabled) {
  $(document).ready(function() {
    $("input.default-value").css("color", inactive_color);
    var default_values = new Array();
    $("input.default-value").focus(function() {
      if (!default_values[this.id]) {
        default_values[this.id] = this.value;
      }
      if (this.value == default_values[this.id]) {
        this.value = '';
        this.style.color = active_color;
      }
      $(this).blur(function() {

        if (this.value == '') {
          this.style.color = inactive_color;
          this.value = default_values[this.id];
        }
      });
    });
  });
}
;
function ProbCriticalNormal(P)
{
//      input p is confidence level convert it to
//      cumulative probability before computing critical

	var   Y, Pr,	Real1, Real2, HOLD;
	var  I;
	var PN = [0,    // ARRAY[1..5] OF REAL
			-0.322232431088  ,
			 -1.0             ,
			 -0.342242088547  ,
			 -0.0204231210245 ,
			 -0.453642210148E-4 ];

	var QN = [0,   //  ARRAY[1..5] OF REAL
			0.0993484626060 ,
			 0.588581570495  ,
			 0.531103462366  ,
			 0.103537752850  ,
			 0.38560700634E-2 ];

	 Pr = 0.5 - P/2; // one side significance


  if ( Pr <=1.0E-8) HOLD = 6;
	else {
			if (Pr == 0.5) HOLD = 0;
			else{
					Y = Math.sqrt ( Math.log( 1.0 / (Pr * Pr) ) );
					Real1 = PN[5];  Real2 = QN[5];

					for ( I=4; I >= 1; I--)
					{
					  Real1 = Real1 * Y + PN[I];
					  Real2 = Real2 * Y + QN[I];
					}

					HOLD = Y + Real1/Real2;
			} // end of else pr = 0.5
		} // end of else Pr <= 1.0E-8

  return HOLD;
}  // end of CriticalNormal

function ProbCriticalNormalPower(P)
{
//      input p is power convert it to
//      cumulative probability before computing critical

	var   Y, Pr,	Real1, Real2, HOLD;
	var  I;
	var PN = [0,    // ARRAY[1..5] OF REAL
			-0.322232431088  ,
			 -1.0             ,
			 -0.342242088547  ,
			 -0.0204231210245 ,
			 -0.453642210148E-4 ];

	var QN = [0,   //  ARRAY[1..5] OF REAL
			0.0993484626060 ,
			 0.588581570495  ,
			 0.531103462366  ,
			 0.103537752850  ,
			 0.38560700634E-2 ];

	 Pr = 1 - P; 


  if ( Pr <=1.0E-8) HOLD = 6;
	else {
			if (Pr == 0.5) HOLD = 0;
			else{
					Y = Math.sqrt ( Math.log( 1.0 / (Pr * Pr) ) );
					Real1 = PN[5];  Real2 = QN[5];

					for ( I=4; I >= 1; I--)
					{
					  Real1 = Real1 * Y + PN[I];
					  Real2 = Real2 * Y + QN[I];
					}

					HOLD = Y + Real1/Real2;
			} // end of else pr = 0.5
		} // end of else Pr <= 1.0E-8

  return HOLD;
}  // end of CriticalNormalPower


function SampleSize(margin,  confidence,  response,  population)
{
     pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = pcn * pcn * response * (100.0 - response);
     d2 = (population - 1.0) * (margin * margin) + d1;
    if (d2 > 0.0)
     return Math.ceil(population * d1 / d2);
    return 0.0;
}

function SampleSizePopMean(margin,  confidence,  variance,  population)
{
     pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = pcn * pcn * variance;
     d2 = (population - 1.0) * (margin * margin) + d1;
    if (d2 > 0.0)
     return Math.ceil(population * d1 / d2);
    return 0.0;
}

function SampleSizeCompareMean(confidence,  power,  difference,  variance)
{
     pcn = ProbCriticalNormal(confidence / 100.0);
     pwr = ProbCriticalNormalPower(power / 100.0);

     d1 = (pcn + pwr);
     d2 = d1*d1*2*variance;
     d3 = difference*difference;
    if (d3 > 0.0)
     return Math.ceil(d2 / d3);
    return 0.0;

}

function SampleSizeCompareProp(confidence, power, response1, response2)
{
     pcn = ProbCriticalNormal(confidence / 100.0);
     pwr = ProbCriticalNormalPower(power / 100.0);

     d1 = (pcn + pwr);
     d2 = d1*d1*(response1*(100.0-response1)+response2*(100.0-response2));
     d3 = (response1 - response2)*(response1-response2);
    if (d3 > 0.0)
     return Math.ceil(d2 / d3);
    return 0.0;

}

function MarginOfError( sample,  confidence,  response,  population)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = pcn * pcn * response * (100.0 - response);
     d2 = d1 * (population - sample) / (sample * (population - 1.0))
    if (d2 > 0.0)
     return Math.sqrt(d2);
    return 0.0;
}

function MarginOfErrorPopMean( sample,  confidence,  variance,  population)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = pcn * pcn * variance;
     d2 = d1 * (population - sample) / (sample * (population - 1.0))
    if (d2 > 0.0)
     return Math.sqrt(d2);
    return 0.0;
}

function ConfidenceIntervalPropLower(prop, confidence, sample)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     pr = prop/100;
     d1 = 1/sample * pr* (1 - pr);
     d2 = pr - pcn * Math.sqrt(d1);
     d3 = d2*100;
     d4 = Math.round(d3*100)/100;
     return d4;
}

function ConfidenceIntervalPropUpper(prop, confidence, sample)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     pr = prop/100;
     d1 = 1/sample * pr* (1 - pr);
     d2 = pr + pcn * Math.sqrt(d1);
     d3 = d2*100;
     d4 = Math.round(d3*100)/100;
     return d4;
}

function ConfidenceIntervalPropLowerFPC(prop, confidence, sample, population)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     pr = prop/100;
     d1 = 1/sample * pr* (1 - pr);
     d2 = (population - sample)/(population - 1);
     d3 = pr - pcn * Math.sqrt(d1*d2);
     d4 = d3*100;
     d5 = Math.round(d4*100)/100;
     return d5;
}

function ConfidenceIntervalPropUpperFPC(prop, confidence, sample, population)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     pr = prop/100;
     d1 = 1/sample * pr* (1 - pr);
     d2 = (population - sample)/(population - 1);
     d3 = pr + pcn * Math.sqrt(d1*d2);
     d4 = d3*100;
     d5 = Math.round(d4*100)/100;
     return d5;
}

function ConfidenceIntervalMeanLower(mean, sdev, confidence, sample)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = 1/Math.sqrt(sample) * sdev;
     d2 = mean - pcn * d1;
     d3 = Math.round(d2*100)/100;
     return d3;
}

function ConfidenceIntervalMeanUpper(mean, sdev, confidence, sample)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = 1/Math.sqrt(sample) * sdev;
     d2 = mean + pcn * d1;
     d3 = Math.round(d2*100)/100;
     return d3;
}

function ConfidenceIntervalMeanLowerFPC(mean, sdev, confidence, sample, population)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = 1/Math.sqrt(sample) * sdev;
     d2 = (population - sample)/(population - 1);
     d3 = mean - pcn * d1 * Math.sqrt(d2);
     d4 = Math.round(d3*100)/100;
     return d4;
}

function ConfidenceIntervalMeanUpperFPC(mean, sdev, confidence, sample, population)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = 1/Math.sqrt(sample) * sdev;
     d2 = (population - sample)/(population - 1);
     d3 = mean + pcn * d1 * Math.sqrt(d2);
     d4 = Math.round(d3*100)/100;
     return d4;
}

function ConfidenceIntervalORLower(a, b, c, d, confidence)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = 1/a+1/b+1/c+1/d;
     d2 = Math.sqrt(d1);
     d3 = (a*d)/(b*c);
     d4 = Math.log(d3);
     d5 = d4-pcn*d2;
     d6 = Math.exp(d5);
     d7 = Math.round(d6*100)/100;
     return d7;
}

function ConfidenceIntervalORUpper(a, b, c, d, confidence)
{
     var pcn = ProbCriticalNormal(confidence / 100.0);
     d1 = 1/a+1/b+1/c+1/d;
     d2 = Math.sqrt(d1);
     d3 = (a*d)/(b*c);
     d4 = Math.log(d3);
     d5 = d4+pcn*d2;
     d6 = Math.exp(d5);
     d7 = Math.round(d6*100)/100;
     return d7;
}

function OddsRatio(a, b, c, d)
{
     d1 = (a*d)/(b*c);
     d2 = Math.round(d1*100)/100;
     return d2;
}


function SampleSizeOR(margin,  confidence,  prevcntrl, oddsrat, sampratio)
{
     pcn = ProbCriticalNormal(confidence / 100.0);
     prevcntrlp = prevcntrl/100
     prevtrtp = (oddsrat*prevcntrlp)/((prevcntrlp*(oddsrat-1))+1);
     d1 = pcn*pcn*((1/(prevtrtp*(1-prevtrtp)*sampratio))+(1/(prevcntrlp*(1-prevcntrlp))));
     d2 = Math.log(1-margin/100);
     d3 = d1/(d2*d2);
     return d3;
}

function DoCalculate()
{
	var ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence1.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample4').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');
	
	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence2.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample5').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');
	
	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence3.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample6').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	var m = MarginOfError(Number(document.ss.sample1.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('margin1').innerHTML=('<b>'+m.toFixed(2).toString()+'%</b');
		    
	m = MarginOfError(Number(document.ss.sample2.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('margin2').innerHTML=('<b>'+m.toFixed(2).toString()+'%</b');
		    
	m = MarginOfError(Number(document.ss.sample3.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('margin3').innerHTML=('<b>'+m.toFixed(2).toString()+'%</b');

 	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population1.value));
	document.getElementById('sample7').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

 	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population2.value));
	document.getElementById('sample8').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

 	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population3.value));
	document.getElementById('sample9').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSize(Number(document.ss.margin1.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample10').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSize(Number(document.ss.margin2.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample11').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSize(Number(document.ss.margin3.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample12').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

 	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response.value), 
		    Number(document.ss.population3.value));
	document.getElementById('sample9').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response1.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample13').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response2.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample14').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSize(Number(document.ss.margin.value),
		    Number(document.ss.confidence.value), 
		    Number(document.ss.response3.value), 
		    Number(document.ss.population.value));
	document.getElementById('sample15').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	return true;
}

function DoCalculate2()
{
	var ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence1.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample4').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');
	
	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence2.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample5').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');
	
	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence3.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample6').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	var m = MarginOfErrorPopMean(Number(document.ss2.sample1.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('margin1').innerHTML=('<b>'+m.toFixed(2).toString()+'%</b');

	m = MarginOfErrorPopMean(Number(document.ss2.sample2.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('margin2').innerHTML=('<b>'+m.toFixed(2).toString()+'%</b');
		    
	m = MarginOfErrorPopMean(Number(document.ss2.sample3.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('margin3').innerHTML=('<b>'+m.toFixed(2).toString()+'%</b');

	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population1.value));
	document.getElementById('sample7').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

 	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population2.value));
	document.getElementById('sample8').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

 	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population3.value));
	document.getElementById('sample9').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin1.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample10').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin2.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample11').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin3.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample12').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance1.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample13').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance2.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample14').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizePopMean(Number(document.ss2.margin.value),
		    Number(document.ss2.confidence.value), 
		    Number(document.ss2.variance3.value), 
		    Number(document.ss2.population.value));
	document.getElementById('sample15').innerHTML=('<b>'+Math.ceil(ss).toString()+'</b');

	return true;
}

function DoCalculate3()
{	
	var ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence1.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample1').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence2.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample2').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence3.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample3').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power1.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample4').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power2.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample5').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power3.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample6').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference1.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample7').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference2.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample8').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference3.value), 
		    Number(document.ss3.variance.value));
	document.getElementById('sample9').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance1.value));
	document.getElementById('sample10').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance2.value));
	document.getElementById('sample11').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareMean(Number(document.ss3.confidence.value),
		    Number(document.ss3.power.value), 
		    Number(document.ss3.difference.value), 
		    Number(document.ss3.variance3.value));
	document.getElementById('sample12').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
		

	return true;

}

function DoCalculate4()
{
	var ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence1.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample1').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence2.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample2').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence3.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample3').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power1.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample4').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power2.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample5').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power3.value), 
		    Number(document.ss4.response1.value), 
		    Number(document.ss4.response2.value));
	document.getElementById('sample6').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response11.value), 
		    Number(document.ss4.response21.value));
	document.getElementById('sample7').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response12.value), 
		    Number(document.ss4.response22.value));
	document.getElementById('sample8').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	ss = SampleSizeCompareProp(Number(document.ss4.confidence.value),
		    Number(document.ss4.power.value), 
		    Number(document.ss4.response13.value), 
		    Number(document.ss4.response23.value));
	document.getElementById('sample9').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');

	return true;

}



function DoCalculate5()
{
	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');


	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop1.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop1.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci1').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop2.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop2.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci2').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop3.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop3.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci3').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence1.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence1.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci4').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');


	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence2.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence2.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci5').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence3.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence3.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci6').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample1.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample1.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci7').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample2.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample2.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci8').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample3.value),
		    Number(document.ss5.population.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample3.value),
		    Number(document.ss5.population.value));
       document.getElementById('ci9').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population1.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population1.value));
       document.getElementById('ci10').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population2.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population2.value));
       document.getElementById('ci11').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalPropLowerFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population3.value));
	var cu = ConfidenceIntervalPropUpperFPC(Number(document.ss5.prop.value),
		    Number(document.ss5.confidence.value),
		    Number(document.ss5.sample.value),
		    Number(document.ss5.population3.value));
       document.getElementById('ci12').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');
	

	return true;
}

function DoCalculate6()
{
	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean1.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean1.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci1').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean2.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean2.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci2').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean3.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean3.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci3').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev1.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev1.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci4').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev2.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev2.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci5').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev3.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev3.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci6').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence1.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence1.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci7').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence2.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence2.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci8').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence3.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence3.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci9').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample1.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample1.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci10').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample2.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample2.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci11').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample3.value),
		    Number(document.ss6.population.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample3.value),
		    Number(document.ss6.population.value));
	document.getElementById('ci12').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population1.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population1.value));
	document.getElementById('ci13').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population2.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population2.value));
	document.getElementById('ci14').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalMeanLowerFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population3.value));
	var cu = ConfidenceIntervalMeanUpperFPC(Number(document.ss6.mean.value),
		    Number(document.ss6.sdev.value),
		    Number(document.ss6.confidence.value),
		    Number(document.ss6.sample.value),
		    Number(document.ss6.population3.value));
	document.getElementById('ci15').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	return true;

}

function DoCalculate7()
{
	var or = OddsRatio(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value));
	document.getElementById('or').innerHTML=(or.toString());

	var cl = ConfidenceIntervalORLower(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence.value));
	var cu = ConfidenceIntervalORUpper(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence.value));
	document.getElementById('ci').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalORLower(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence1.value));
	var cu = ConfidenceIntervalORUpper(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence1.value));
	document.getElementById('ci1').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalORLower(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence2.value));
	var cu = ConfidenceIntervalORUpper(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence2.value));
	document.getElementById('ci2').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	var cl = ConfidenceIntervalORLower(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence3.value));
	var cu = ConfidenceIntervalORUpper(Number(document.ss7.a.value),
		    Number(document.ss7.b.value),
		    Number(document.ss7.c.value),
		    Number(document.ss7.d.value),
		    Number(document.ss7.confidence3.value));
	document.getElementById('ci3').innerHTML=('('+cl.toString()+' , '+cu.toString()+')');

	return true;
}

function DoCalculate8()
{
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin1.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample1').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin2.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample2').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin3.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample3').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence1.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample4').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence2.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample5').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence3.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample6').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl1.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample7').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl2.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample8').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl3.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample9').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat1.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample10').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat2.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample11').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat3.value),
		    Number(document.ss8.sampratio.value));
	document.getElementById('sample12').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio1.value));
	document.getElementById('sample13').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio2.value));
	document.getElementById('sample14').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	var ss = SampleSizeOR(Number(document.ss8.margin.value),
		    Number(document.ss8.confidence.value), 
		    Number(document.ss8.prevcntrl.value), 
		    Number(document.ss8.oddsrat.value),
		    Number(document.ss8.sampratio3.value));
	document.getElementById('sample15').innerHTML=('<b style="font-size:14pt">'+Math.ceil(ss).toString()+'</b');
	
	return true;
}
;

function LogGamma(Z) {
	with (Math) {
		var S=1+76.18009173/Z-86.50532033/(Z+1)+24.01409822/(Z+2)-1.231739516/(Z+3)+.00120858003/(Z+4)-.00000536382/(Z+5);
		var LG= (Z-.5)*log(Z+4.5)-(Z+4.5)+log(S*2.50662827465);
	}
	return LG
}

function Betinc(X,A,B) {
	var A0=0;
	var B0=1;
	var A1=1;
	var B1=1;
	var M9=0;
	var A2=0;
	var C9;
	while (Math.abs((A1-A2)/A1)>.00001) {
		A2=A1;
		C9=-(A+M9)*(A+B+M9)*X/(A+2*M9)/(A+2*M9+1);
		A0=A1+C9*A0;
		B0=B1+C9*B0;
		M9=M9+1;
		C9=M9*(B-M9)*X/(A+2*M9-1)/(A+2*M9);
		A1=A0+C9*A1;
		B1=B0+C9*B1;
		A0=A0/B1;
		B0=B0/B1;
		A1=A1/B1;
		B1=1;
	}
	return A1/A
}

function tdist(X,df) {
    with (Math) {
		//if (df<=0) {
		//	alert("Degrees of freedom must be positive")
		//} else {
			A=df/2;
			S=A+.5;
			Z=df/(df+X*X);
			BT=exp(LogGamma(S)-LogGamma(.5)-LogGamma(A)+A*log(Z)+.5*log(1-Z));
			if (Z<(A+1)/(S+2)) {
				betacdf=BT*Betinc(Z,A,.5)
			} else {
				betacdf=1-BT*Betinc(1-Z,.5,A)
			}
			if (X<0) {
				tcdf=betacdf/2
			} else {
				tcdf=1-betacdf/2
			}
		//}
	}
    return tcdf;
}

function GetPVal(m1,m2,s1,s2,n1,n2)
{
	var v1 = s1*s1
	var v2 = s2*s2
	var s = Math.sqrt(v1/n1+v2/n2);
	var t = (m1-m2)/s;
	var df = Math.pow(v1/n1+v2/n2,2)/(Math.pow(v1/n1,2)/(n1-1) + Math.pow(v2/n2,2)/(n2-1));
	var p1 = tdist(t,df);
	var p2 = 1-p1;
	var p = Math.min(p1,p2);
	var pv = 2*p;
	if (pv<0.001){
		var output = '<0.001';
	} else{
		pv = Math.round(pv*1000)/1000;
		var output = pv.toString();
	}
	return output;
}

function DoCalculate10()
{
	var n1 = Number(document.ss6.sample1.value);
	var n2 = Number(document.ss6.sample2.value);
	var v1 = Number(document.ss6.sdev1.value)*Number(document.ss6.sdev1.value);
	var v2 = Number(document.ss6.sdev2.value)*Number(document.ss6.sdev2.value);
	var s = Math.sqrt(v1/n1+v2/n2);
	var t = (Number(document.ss6.mean1.value)-Number(document.ss6.mean2.value))/s;
	var df = Math.pow(v1/n1+v2/n2,2)/(Math.pow(v1/n1,2)/(n1-1) + Math.pow(v2/n2,2)/(n2-1));
	var p1 = tdist(t,df);
	var p2 = 1-p1;
	var p = Math.min(p1,p2);
	var pv = 2*p;
	pv = Math.round(pv*1000)/1000;
	if (pv<0.001){
		document.getElementById('pval').innerHTML='<0.001';
	} else{
		document.getElementById('pval').innerHTML=pv;
	}
}

function DoCalculate11(){
	var pv = GetPVal(Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean12.value),
		Number(document.ss6.mean22.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval2').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean13.value),
		Number(document.ss6.mean23.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval3').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean14.value),
		Number(document.ss6.mean24.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval4').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev15.value),
		Number(document.ss6.sdev25.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval5').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev16.value),
		Number(document.ss6.sdev26.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval6').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev17.value),
		Number(document.ss6.sdev27.value),
		Number(document.ss6.sample1.value),
		Number(document.ss6.sample2.value));
		document.getElementById('pval7').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample18.value),
		Number(document.ss6.sample28.value));
		document.getElementById('pval8').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample19.value),
		Number(document.ss6.sample29.value));
		document.getElementById('pval9').innerHTML=pv;
		
	var pv = GetPVal(
		Number(document.ss6.mean1.value),
		Number(document.ss6.mean2.value),
		Number(document.ss6.sdev1.value),
		Number(document.ss6.sdev2.value),
		Number(document.ss6.sample110.value),
		Number(document.ss6.sample210.value));
		document.getElementById('pval10').innerHTML=pv;
		
}
;
