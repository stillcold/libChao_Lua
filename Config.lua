local config = {
	file_encode_config = {
		encode_key = "xiaoxiao",
		encode_len = 100,
		encode_tail = ".sherry",
		encode_map = {
			-- fileName, encode_algrithm_version, use_binary_encode
			{"UrlAnalysis/UrlAnalysisMgr.lua" , 1, false},
			{"Misc/ApphelperAlmostDoneLogParser.lua" , 1, false},
			{"Misc/almostdone.txt" , 1, false},
			{"Common/json.lua" , 1, false},
			{"LogAnalysis/BILogReader.lua" , 1, false},
		}
	}
	
}


return config
