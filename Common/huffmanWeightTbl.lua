-- Build / Select in WeightTbl
-- See __Test_Suite() for usage.

local huffmanWeightTbl = {}

function huffmanWeightTbl:BuildHuffmanTree(keyValueTbl)
	local sortTbl = {}
	local orginalTotalWeight = 0
	for k,v in pairs(keyValueTbl) do
		table.insert(sortTbl, {k,v})
		orginalTotalWeight = orginalTotalWeight + v
	end

	local sortfunction = function(e1, e2)
		if e1[2] < e2[2] then return true end
	end

	table.sort(sortTbl, sortfunction)

	local nodeCount = #sortTbl

	local weighlessNode = {key = sortTbl[1][1], bIsLeaf = true}
	local lastRoundTotalWeight = sortTbl[1][2] / orginalTotalWeight

	local previousNode = weighlessNode

	for i = 2, nodeCount do
		local node = {key = sortTbl[i][1], bIsLeaf = true}
		local newParent = {leftWeight = sortTbl[i][2] / orginalTotalWeight}

		newParent[1] = node 		-- left
		newParent[2] = previousNode -- right

		previousNode = newParent

		lastRoundTotalWeight = (sortTbl[i][2] + lastRoundTotalWeight) / orginalTotalWeight
	end

	return previousNode
end

function huffmanWeightTbl:SelectInHuffmanTree(tree, randomNum)
	randomNum = randomNum or math.random()
	local nextNode = tree
	while (nextNode and (not nextNode.bIsLeaf) ) do
		if randomNum <= nextNode.leftWeight then
			nextNode = nextNode[1]
		else
			randomNum = randomNum - nextNode.leftWeight
			nextNode = nextNode[2]
		end
	end

	return nextNode and nextNode.key or 0
end

function huffmanWeightTbl:ShowHuffmanTree(tree, level)

	level = level or 0
	if tree.bIsLeaf then
		print(tree.key)
		return
	end

	print("level:",level,"left weight is",tree.leftWeight,"\n")

	local left = tree[1]
	local right = tree[2]

	self:ShowHuffmanTree(left, level + 1)
	self:ShowHuffmanTree(right, level + 1)
end


function huffmanWeightTbl:__Test_Suite()
	local tbl = {}
	tbl[1001] = 100
	tbl[1002] = 10
	tbl[1003] = 1
	tbl[1004] = 0.1

	local tree = self:BuildHuffmanTree(tbl)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 1))
end

return huffmanWeightTbl
