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
posV=1500       --position Vertical (high-low)
skyH=0          --position of Sky

spd=0           --speed
prog=0          --current progress on the track 
trackX=0        --horizontal position of the track
trackLen = 2000 --length of the track
dH = 40         --left right delta by keys


function keys()

	if btn(0) and spd < 250 then spd=spd+1 end
	if btn(1) and spd > 0 then spd=spd-1 end
	if btn(2) and spd > 0 then 
	  posH = posH + dH
		 skyH = skyH + 1
 end
	if btn(3) and spd > 0 then 
	  posH = posH - dH
		 skyH = skyH - 1
 end
end



function drawQuad( x1, y1, w1, x2, y2, w2, color)

 tri( x1-w1, y1, x1+w1, y1, x2-w2, y2, color) 	
 tri( x2-w2, y2, x1+w1, y1, x2+w2, y2, color) 	
	
end

function trackSeg(ax,ay,az,aw,c)

 return {x	= ax,	
        y = ay,
        z = az,
        w = aw,
	      	curve = c}	
end

function project(seg, camX, camY, camZ)

  if seg.z == camZ then 
	   scale = camD	
  elseif seg.z <= camZ then --second lap
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

  if seg > 300 and seg < 928 then 
		  return (1+math.cos(3.14+ (seg-300) / 33.3)) * 2000 
		end
		
		if seg > 1500 and seg < 1814 then
		  return (1+math.cos(3.14+ (seg-1500) / 33.3)) * 3000 
		end
		
		return 0
end		
	
function calcCurve(seg)

		if seg > 100 and seg < 150 then return 1.0 end 
		if seg > 149 and seg < 300 then return 2.0 end 

		if seg > 700 and seg < 750 then return -1.0 end 
		if seg > 749 and seg < 900 then return -2.0 end 

		if seg > 1000 and seg < 1050 then return -1.0 end 
		if seg > 1099 and seg < 1300 then return -2.0 end 
		if seg > 1299 and seg < 1500 then return 2.0 end
		
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

function drawSprites(seg)

end


---main

track = createTrack()

maxProg = trackLen * segL

fps = 60
cfps = 0

lastFrameSec = time()
posH=0

function TIC() --main function

	
	t = time()
	
	if t > lastFrameSec + 1000 then
	  lastFrameSec = t
			fps = cfps
			cfps = 1 
	else
	  cfps = cfps + 1
	end
	
	keys()
	
	prog = prog + spd
	
	curr = prog // segL	

 --draw sky
	cls(13)

	spr(64, (skyH+100)%resW, 5, -1, 1,0,0,4,4)
	spr(64, (skyH+20)%resW, 25, -1, 1,0,0,4,4)
	spr(64, (skyH+200)%resW, 15, -1, 1,0,0,4,4)
	
 --draw track
 cp = curr % trackLen
 seg = track[cp]
	pX,pY,pW = project(seg, posH, posV, prog)
	
	posH = posH - seg.curve * spd * 0.1
	posY = seg.y + posV
	dx = 0
	xx = 0
 minY = resH
 for n = curr+1, curr+150 do
	  
			c = n % trackLen
			seg = track[c]
		
		 xx = xx + dx
			dx = dx + seg.curve
			--trace("x:"..x.." dx"..dx)
			
			X,Y,W = project(seg, xx - posH, posY, prog)

   if minY > Y then 
--trace("curr:" .. curr .." c:".. c.." prog:"..progM.." Y"..Y)
				
				far = pY-Y < 0.09
				
				alt = (n // 4) % 2 == 0
						
			 if far or alt then grass=11 else grass=5 end
			
				if far or alt then rumble=15 else rumble=6 end
			
			 if far or alt then road=7 else road=3 end
	
	  
	   drawQuad(0,  pY, resW,    0, Y, resW, grass)	
	   drawQuad(pX, pY, pW *1.2, X , Y, W *1.2, rumble)	
	   drawQuad(pX, pY,	pW,      X	, Y, W, road)	

				if alt then
					 drawQuad(pX + pW *0.33, pY, pW *0.02, X + W *0.33, Y, W *0.02, rumble)	
			   drawQuad(pX - pW *0.33, pY, pW *0.02, X - W *0.33, Y, W *0.02, rumble)	
			  
				end
    minY = Y
   end
			
			--draw objects
			for n = curr+1, curr+150 do
	 		c = n % trackLen
				seg = track[c]
				
    drawSprites(seg)
			end	  
			
			
			pX = X
			pY = Y
			pW = W
			
	end
	
	print("s:"..spd.." d:"..cp.."  "..fps)

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
-- 064:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00
-- 065:dddddddddddddddddddd0d00ddd0f0ffd00fffffd0ffffff0fffffff0ffffff2
-- 066:dddddddddddddddd0dddddddf0ddddddff0dddddff200dddf2a220dd2affa200
-- 067:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 080:ddd000fad00fffff0fffffffd0ffffff0fffffff0fffffffd0ffffff0fffffff
-- 081:a22ffffafaa2fffffff22ffffffa22ffffffa2ffffff2fffffa2ffffffffffff
-- 082:affffafffffffffffffffffffffffffffffffffffffffff2fffff22affffffff
-- 083:000dddddfff0ddddffff00ddf222ff0d2aa22f20affa2f20ffffaf20fffff20d
-- 096:d0ffffffd00fffafddd02aa2ddd00220ddddd00ddddddddddddddddddddddddd
-- 097:ffffffffffffffffff2affff22022aff00d00aaadddd0222ddddd002ddddddd0
-- 098:ffffffffffffffffffffffffafffaffaafaa22aaaa2200222200dd0000dddddd
-- 099:fffff20dfffff20dffffff20fffaff20afaaa2202220200d000d0ddddddddddd
-- 112:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 113:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 114:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 115:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
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
-- 000:140c1c44243459a1ce616155854c30488d28d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>
