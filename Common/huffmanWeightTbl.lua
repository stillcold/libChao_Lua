-- Build / Select in WeightTbl
-- See __Test_Suite() for usage.

local huffmanWeightTbl = {}

function huffmanWeightTbl:_BuildSimpleHuffmanTree(keyValueTbl)
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
	local treeIndex = {}

	for i = 2, nodeCount do
		local node = {key = sortTbl[i][1], bIsLeaf = true}

		if treeIndex[sortTbl[i][1]] then
			print("repeat key detected in original weight table")
			return
		end

		treeIndex[sortTbl[i][1]] = node

		local newParent = {leftWeight = sortTbl[i][2] / orginalTotalWeight}

		newParent[1] = node 		-- left
		newParent[2] = previousNode -- right

		previousNode = newParent

		lastRoundTotalWeight = (sortTbl[i][2] + lastRoundTotalWeight) / orginalTotalWeight
	end

	return previousNode
end

function huffmanWeightTbl:_BuildAdjustableTree(keyValueTbl)
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

	local weighlessNode = {key = sortTbl[1][1], bIsLeaf = true, originalWeight = sortTbl[1][2]}
	local lastRoundTotalWeight = sortTbl[1][2]

	local previousNode = weighlessNode
	local treeIndex = {}
	treeIndex[sortTbl[1][1]] = weighlessNode

	for i = 2, nodeCount do
		local node = {key = sortTbl[i][1], bIsLeaf = true, originalWeight = sortTbl[i][2]}

		if treeIndex[sortTbl[i][1]] then
			print("repeat key detected in original weight table")
			return
		end

		treeIndex[sortTbl[i][1]] = node

		local newParent = {leftWeight = sortTbl[i][2]}

		newParent[1] = node 		-- left
		newParent[2] = previousNode -- right

		node.parent = newParent
		previousNode.parent = newParent

		previousNode = newParent

		lastRoundTotalWeight = (sortTbl[i][2] + lastRoundTotalWeight)
	end

	previousNode.treeIndex = treeIndex
	previousNode.bAdjustableTree = true
	previousNode.adjustTimes = 0
	previousNode.totalWeight = lastRoundTotalWeight
	previousNode.totalCount = nodeCount

	return previousNode
end

-- set bAdjustableTree with record many more info
-- in this case, the built tree and can be adjusted easier
-- if you want to adjust the weight value after build the tree, do use it!
function huffmanWeightTbl:BuildHuffmanTree(keyValueTbl, bAdjustableTree)
	if bAdjustableTree then
		return self:_BuildAdjustableTree(keyValueTbl)
	end

	return self:_BuildSimpleHuffmanTree(keyValueTbl)
end

function huffmanWeightTbl:SelectInHuffmanTree(tree, randomNum)
	if not randomNum then
		randomNum = math.random()
		if tree.bAdjustableTree then
			randomNum = randomNum * tree.totalWeight
		end
	end

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

-- The tree will not be a huffman tree after adjust
function huffmanWeightTbl:AdjustWeightTree(tree, key, newWeight)
	if not tree.bAdjustableTree then return end

	-- Ajust too mnany times, build a new huffman tree instead
	if (tree.adjustTimes / tree.totalCount >= 0.5 ) or (tree.totalCount <= 1)  then
		local oldTree = tree
		local keyValueTbl = {}
		for k,v in pairs(oldTree.treeIndex) do
			keyValueTbl[k] = v.originalWeight
		end

		keyValueTbl[key] = newWeight

		tree = self:_BuildAdjustableTree(keyValueTbl, true)
		return tree
	end

	local targetNode = tree.treeIndex[key]
	if not targetNode then

		local newNode = {key = key, bIsLeaf = true, originalWeight = newWeight}

		local oldTree = tree

		tree = {}
		tree[1] = newNode
		tree[2] = oldTree
		tree.leftWeight = newWeight

		tree.treeIndex = oldTree.treeIndex

		tree.treeIndex[key] = newNode
		tree.totalWeight = oldTree.totalWeight + newWeight
		tree.adjustTimes = 1 + oldTree.adjustTimes
		tree.totalCount = oldTree.totalCount + 1
		tree.bAdjustableTree = true

		oldTree.treeIndex = nil
		oldTree.totalWeight = nil
		oldTree.totalCount = nil
		oldTree.adjustTimes = nil
		oldTree.bAdjustableTree = nil
		return tree
	end

	local offset = (newWeight - targetNode.originalWeight)
	targetNode.originalWeight = newWeight

	local parent = targetNode.parent
	if not parent then return end

	parent.leftWeight = newWeight

	tree.totalWeight = tree.totalWeight + offset
	tree.adjustTimes = 1 + tree.adjustTimes

	return tree
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

	print("build simple tree --------")
	local tree = self:BuildHuffmanTree(tbl)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 0.9), "should be 1001")
	print(self:SelectInHuffmanTree(tree, 0.99), "should be 1002")
	print(self:SelectInHuffmanTree(tree, 0.999), "should be 1003")
	print(self:SelectInHuffmanTree(tree, 0.9999), "should be 1004")

	print("build adjustable tree --------")
	local tree = self:BuildHuffmanTree(tbl, true)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 100), "should be 1001")
	print(self:SelectInHuffmanTree(tree, 110), "should be 1002")
	print(self:SelectInHuffmanTree(tree, 111), "should be 1003")
	print(self:SelectInHuffmanTree(tree, 111.1), "should be 1004")

	print("adjust adjustable tree --------")
	tree = self:AdjustWeightTree(tree, 1003, 2)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 100), "should be 1001")
	print(self:SelectInHuffmanTree(tree, 110), "should be 1002")
	print(self:SelectInHuffmanTree(tree, 111), "should be 1003")
	print(self:SelectInHuffmanTree(tree, 111.1), "should be 1003")
	print(self:SelectInHuffmanTree(tree, 112), "should be 1003")
	print(self:SelectInHuffmanTree(tree, 112.1), "should be 1004")

	print("adjust adjustable tree --------")
	tree = self:AdjustWeightTree(tree, 1005, 3)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 3), "should be 1005")
	print(self:SelectInHuffmanTree(tree, 103), "should be 1001")
	print(self:SelectInHuffmanTree(tree, 113), "should be 1002")
	print(self:SelectInHuffmanTree(tree, 115), "should be 1003")
	print(self:SelectInHuffmanTree(tree, 115.1), "should be 1004")


	tbl = {}
	tbl[1001] = 100
	print("build adjustable tree --------")
	local tree = self:BuildHuffmanTree(tbl, true)
	print("show tree --------")
	self:ShowHuffmanTree(tree)
	print("adjust adjustable tree --------")
	tree = self:AdjustWeightTree(tree, 1005, 3)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 100), "should be 1001")
	print(self:SelectInHuffmanTree(tree, 102), "should be 1005")
	print(self:SelectInHuffmanTree(tree, 103), "should be 1005")

	print("adjust adjustable tree --------")
	tree = self:AdjustWeightTree(tree, 1006, 3)
	print("show tree --------")
	self:ShowHuffmanTree(tree)

	print("select res --------")
	print(self:SelectInHuffmanTree(tree, 3), "should be 1006")
	print(self:SelectInHuffmanTree(tree, 103), "should be 1001")
	print(self:SelectInHuffmanTree(tree, 104), "should be 1005")
end

return huffmanWeightTbl
