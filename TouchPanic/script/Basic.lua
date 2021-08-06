
    tab={["0"]="0000",["1"]="0001",["2"]="0010",["3"]="0011",
         ["4"]="0100",["5"]="0101",["6"]="0110",["7"]="0111",
         ["8"]="1000",["9"]="1001",["a"]="1010",["b"]="1011",
         ["c"]="1100",["d"]="1101",["e"]="1110",["f"]="1111",
         ["A"]="1010",["B"]="1011",["C"]="1100",["D"]="1101",["E"]="1110",["F"]="1111"}
   
gui.register(function()
	
	--動画モード
	agg.text(0, 18, string.format("%s", movie.mode()))
	
	--ボールスタック
	local y = 186
	local ballMark = {"P", "-", "S", "H", "C", "D"}
	local mark0 = memory.readdword(0x021EBB3C)
	if (0 <= mark0 and mark0 <= 5) then
		agg.text(0, y, "next: " .. string.format("%s", ballMark[mark0 + 1]))
	end

	for i = 0, 23 do
		local mark = memory.readdword(0x021EC4B8 + 24 * i)
		if (0 <= mark and mark <= 5) then
			agg.text(33 + 9 * i, y, string.format("%s", ballMark[mark + 1]))
		end
	end
	
	local panel = {}
	local ball = {}
	
	--パネル情報
	for i = 0, 47 do
		panel[i] = {
			x = 32 * memory.readdword(0x021EAEE4 + 40 * i),
			y = 32 * memory.readdword(0x021EAEE8 + 40 * i),
			selected = memory.readdword(0x021EAEFC + 40 * i)
		}
		
		--移動する一瞬のみ表示
		--if (panel[i].selected == 1) then 
		--	gui.box(16 + panel[i].x, 0 + panel[i].y, 48 + panel[i].x, 32 + panel[i].y, "yellow")
		--end
	end
	
	--ボール情報
	for i = 0, 16 do
		ball[i] = {
			mark = memory.readdword(0x021EBB54 + 140 * i),
			id = memory.readdword(0x021EBB88 + 140 * i),
			speed = memory.readdword(0x021EBBA8 + 140 * i)
			
		}
		-- gui.text(0, 9 * i, string.format("%x, %d", 0x021EBB54 + 140 * i, ball[i].mark))
	end
	
	for i = 0, 16 do
		if (0 <= ball[i].mark and ball[i].mark <= 5) then
			local id = ball[i].id
			if (0 <= id and id <= 47) then
				gui.opacity(0.2)
				gui.box(16 + panel[id].x, 0 + panel[id].y, 48 + panel[id].x, 32 + panel[id].y, "yellow")
				gui.opacity(1.0)
				gui.box(16 + panel[id].x, 0 + panel[id].y, 48 + panel[id].x, 32 + panel[id].y, "", "black")
			end
		end
	end
	
	for i = 0, 16 do
		if (0 <= ball[i].mark and ball[i].mark <= 5) then
			local id = ball[i].id
			if (0 <= id and id <= 47) then
				gui.text(16 + (ball[i].mark % 4) * 7 + panel[id].x, 1 + math.floor(ball[i].mark / 4) * 8 + panel[id].y, ballMark[ball[i].mark + 1])
			end
		end
	end
	
	agg.text(0, 194, "next ball:" .. string.format("%s", memory.readdword(0x021EBB34)))
	
end)

function hex2float (c)
    if c == 0 then return 0.0 end
    local c = string.gsub(string.format("%X", c),"(..)",function (x) return string.char(tonumber(x, 16)) end)
    local b1,b2,b3,b4 = string.byte(c, 1, 4)
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x2 + math.floor(b2 / 0x80)
    local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4

    if sign then
        sign = -1
    else
        sign = 1
    end

    local n

    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0xFF then
        if mant == 0 then
            n = sign * math.huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * math.ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end

    return n
end
