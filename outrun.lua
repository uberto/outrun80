-- title:  Outrun80
-- author: Uberto Barbini
-- desc:   Pseudo 3d car simulator
-- script: lua


--screen res
resW=240
resH=136

halfW=resW/2	
halfH=resH/2


roadW=2000 --road width
segL=400   --track segment lenght
camD=0.84  --camera depth


posH=0          --position Horizontal (left-right)
posV=1500       --position Vertical (high-low)
spd=0           --speed
prog=0          --current progress on the track 
trackX=0        --horizontal position of the track
trackLen = 2000 --length of the track
dH = 60         --left right delta by keys


function keys()

	if btn(0) and spd < 180 then spd=spd+1 end
	if btn(1) and spd > 0 then spd=spd-1 end
	if btn(2) and spd > 0 then posH=posH + dH end
	if btn(3) and spd > 0 then posH=posH - dH end
end



function drawQuad( x1, y1, w1, x2, y2, w2, color)

 tri( x1-w1, y1, x1+w1, y1, x2-w2, y2, color) 	
 tri( x2-w2, y2, x1+w1, y1, x2+w2, y2, color) 	
	
end

function trackSeg(ax,ay,az,aw,c)

 return 	{x	= ax,	
         	y = ay,
         	z = az,
          w = aw,
										curve = c}	
end

function project(seg, camX, camY, camZ)

  if seg.z == camZ then 
	   scale = camD	
  elseif seg.z <= camZ then 
		  trace("!!! segz:"..seg.z.." camZ"..camZ)

	   scale = camD / (seg.z + maxProg - camZ)	
		else 
	   scale = camD / (seg.z - camZ)	
		end
--	trace("project x"..seg.x.." y"..seg.y.." z"..seg.z)
--	trace("project camX"..camX.." camY"..camY.." camZ"..camZ)

 
	X = (1 + scale*(seg.x-camX)) * halfW		
	Y = (1 - scale*(seg.y-camY)) * halfH
	W = scale * seg.w * halfW
	
--		trace("project X"..X.." Y"..Y.." W"..W.." s"..scale)
	return X, Y, W
end

function calcHeight(seg)

  if seg > 300 and seg < 700 then 
		  return math.sin( (seg-300) / 30) * 1250 
		end
		
		if seg > 1500 and seg < 1800 then
		  return math.sin( (seg-1500) / 30) * 125	0 
		end
		
		return 0
end		
	
function calcCurve(seg)

		if seg > 100 and seg < 200 then return 0.5 end 
		if seg > 100 and seg < 300 then return 1.0 end 

		if seg > 700 and seg < 800 then return -1.0 end 
		if seg > 800 and seg < 900 then return -1.5 end 

		if seg > 1000 and seg < 1100 then return -0.5 end 
		if seg > 1100 and seg < 1200 then return -1.5 end 
		if seg > 1300 and seg < 1400 then return 2.0 end
		
		return 0
end


function createTrack()
  t = {}
  for i=0, trackLen do
		
    t[i] = trackSeg(0,calcHeight(i),1+i*segL,roadW,calcCurve(i))
  end
		
		trace("prepared track " .. trackLen)
		
		return t
end

---

track = createTrack()

maxProg = trackLen * segL

function TIC()
--main function
	cls(13)
	
	keys()
	
	prog = prog + spd
	
	curr = prog // segL	

 cp = curr % trackLen
 seg = track[cp]
	pX,pY,pW = project(seg, posH, posV, prog)
	
	posH = posH - seg.curve * spd * 0.2
	dx = 0
	xx = 0
 minY = resH
 for n = curr+1, curr+100 do
	  
			c = n % trackLen
			seg = track[c]
		
		 xx = xx + dx
			dx = dx + seg.curve
			--trace("x:"..x.." dx"..dx)
			
			X,Y,W = project(seg, xx - posH, posV, prog)

   if minY > Y then 
--trace("curr:" .. curr .." c:".. c.." prog:"..progM.." Y"..Y)
				
				alt = (n // 4) % 2 == 0
				
						
			 if alt then grass=5 else grass=11 end
			
				if alt then rumble=0 else rumble=15 end
			
			 if alt then road=3 else road=7 end
	
	  
	   drawQuad(0,  pY, resW,    0, Y, resW, grass)	
	   drawQuad(pX, pY, pW *1.1, X , Y, W *1.1, rumble)	
	   drawQuad(pX, pY,	pW,      X	, Y, W, road)	

    minY = Y
   end
			pX = X
			pY = Y
			pW = W
			
	end
	
	print("s:"..spd.."  p:"..cp)

end

-- <TILES>
-- 001:efffffffff222222f8888888f8222222f8fffffff8ff0ffff8ff0ffff8ff0fff
-- 002:fffffeee2222ffee88880fee22280feefff80fff0ff80f0f0ff80f0f0ff80f0f
-- 003:efffffffff222222f8888888f8222222f8fffffff8fffffff8ff0ffff8ff0fff
-- 004:fffffeee2222ffee88880fee22280feefff80ffffff80f0f0ff80f0f0ff80f0f
-- 017:f8fffffff8888888f888f888f8888ffff8888888f2222222ff000fffefffffef
-- 018:fff800ff88880ffef8880fee88880fee88880fee2222ffee000ffeeeffffeeee
-- 019:f8fffffff8888888f888f888f8888ffff8888888f2222222ff000fffefffffef
-- 020:fff800ff88880ffef8880fee88880fee88880fee2222ffee000ffeeeffffeeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>
