-- =======================================================================================
--
-- Debug facility
-- 
-- Include this script to output debug messages
--
-- 
-- =======================================================================================


-- =======================================================================================
--
-- Script-global variables
-- 
-- =======================================================================================
--
dbg = {}
-- 
-- =======================================================================================


-- =======================================================================================
--
-- Print function
--
-- Usage :
--    dbg.stdOutput( strPrefixParam, numIndentParam, strMessageParam, boolDebugParam )
-- 
-- =======================================================================================
--
function dbg.stdOutput(strPrefixParam, numIndentParam, strMessageParam, boolDebugParam)
	-- Local variables with default values
	local strPrefix  = ""
	local numIndent  = 0
	local strMessage = ""
	local boolDebug = true

	-- Debug : try not to print anything
	if true then
		return
	end

	-- Check boolean parameter
	if type(boolDebugParam)=="boolean" then
		if boolDebugParam then
			print ( string.format( "strPrefixParam : \"%s\", numIndentParam : %i, strMessageParam : \"%s\", boolDebugParam : %s", strPrefixParam, numIndentParam, strMessageParam, tostring(boolDebugParam) ) )
		else
			return
		end
	else
		return
	end

	-- Check the other parameters
	if type(strPrefixParam)=="string" then
		strPrefix  = strPrefixParam
	else
		return
	end
	if type(numIndentParam)=="number" then
		numIndent  = numIndentParam
	else
		return
	end
	if type(strMessageParam)=="string" then
		strMessage = strMessageParam
	else
		return
	end

	-- Built indentation and line feed strings
	local strIndent = ""
	local strLF = ""
	if numIndent>=0 then
		strIndent = string.rep("    ", numIndent)
	end
	if numIndent<0 then
		strLF = "\n"
	end

	-- Print message
	if boolDebug then
		local tabDateTime = os.date("*t")
		local strDate = string.format( "%02i", tabDateTime.day ) .. "/" .. string.format( "%02i", tabDateTime.month ) .. "/" .. string.format( "%04i", tabDateTime.year )
		local strTime = string.format( "%02i", tabDateTime.hour ) .. "." .. string.format( "%02i", tabDateTime.min ) .. "." .. string.format( "%02i", tabDateTime.sec )
		local strInGameTime = time.str()
		print ( strInGameTime )
		local strPrintedString = string.format( "%s(%s:%s) (%s) : %s : %s%s", strLF, strDate, strTime, strInGameTime, strPrefix, strIndent, strMessage )
		print("===> dbg.stdOutput : before print(strPrintedString) statement")
		print ( string.format( "strPrintedString : \"%s\"", strPrintedString ) )
		print("===> dbg.stdOutput : before print statement")
		print ( strPrintedString )
		print("===> dbg.stdOutput : after print statement")
	end
end
-- 
-- =======================================================================================
