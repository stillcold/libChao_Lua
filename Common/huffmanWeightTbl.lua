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

	local root = {}
	root.bIsWeightTree = true

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

	root.tree = previousNode

	return root
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

	local root = {}
	root.bIsWeightTree = true

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

	root.tree = previousNode

	root.treeIndex = treeIndex
	root.bAdjustableTree = true
	root.adjustTimes = 0
	root.totalWeight = lastRoundTotalWeight
	root.totalCount = nodeCount

	return root
end

-- Set bAdjustableTree with record many more info
-- In this case, the built tree and can be adjusted easier
-- If you want to adjust the weight value after build the tree, do use it!
function huffmanWeightTbl:BuildHuffmanTree(keyValueTbl, bAdjustableTree)
	if bAdjustableTree then
		return self:_BuildAdjustableTree(keyValueTbl)
	end

	return self:_BuildSimpleHuffmanTree(keyValueTbl)
end

function huffmanWeightTbl:_SelectInHuffmanTree(tree, randomNum)
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

function huffmanWeightTbl:SelectInHuffmanTree(root, randomNum)
	return self:_SelectInHuffmanTree(root.tree, randomNum)
end

function huffmanWeightTbl:IsWeightTree(root)
	if not root then return false end
	if root.bIsWeightTree then return true end
end

-- One api for all
-- If input is not a valid weight tree, it will build a new tree
-- The tree will not be a huffman tree after adjust
-- In case input is not a tree or a nil value, it returns a tree anyway
function huffmanWeightTbl:AdjustWeightTree(root, key, newWeight)
	if not key then return root end

	if newWeight < 0 then newWeight = 0 end

	if not root or not self:IsWeightTree(root) then
		local tbl = {}

		tbl[key] = newWeight

		return self:BuildHuffmanTree(tbl, true)
	end

	-- This is helpless
	if not root.bAdjustableTree then
		return root
	end

	local tree = root.tree

	-- Ajust too mnany times, build a new huffman tree instead
	if (root.adjustTimes / root.totalCount >= 0.5 ) or (root.totalCount <= 1)  then
		local keyValueTbl = {}
		for k,v in pairs(root.treeIndex) do
			keyValueTbl[k] = v.originalWeight
		end

		keyValueTbl[key] = newWeight

		root = self:_BuildAdjustableTree(keyValueTbl, true)
		return root
	end

	local targetNode = root.treeIndex[key]
	if not targetNode then

		local newNode = {key = key, bIsLeaf = true, originalWeight = newWeight}

		local oldTree = tree

		tree = {}
		tree[1] = newNode
		tree[2] = oldTree
		tree.leftWeight = newWeight

		root.tree = tree
		root.treeIndex[key] = newNode
		root.totalWeight = root.totalWeight + newWeight
		root.adjustTimes = 1 + root.adjustTimes
		root.totalCount = root.totalCount + 1
		root.bAdjustableTree = true

		return root
	end

	local offset = (newWeight - targetNode.originalWeight)
	targetNode.originalWeight = newWeight

	local parent = targetNode.parent
	if not parent then return end

	parent.leftWeight = newWeight

	root.totalWeight = root.totalWeight + offset
	root.adjustTimes = 1 + root.adjustTimes

	return root
end

function huffmanWeightTbl:AddKeyWeight(root, key, addValue)

	if not key then return end

	if not root or not self:IsWeightTree(root) then
		local tbl = {}
		if addValue < 0 then addValue = 0 end
		tbl[key] = addValue

		return self:BuildHuffmanTree(tbl, true)
	end

	if not root.bAdjustableTree then return root end

	local targetNode = root.treeIndex[key]
	if not targetNode then
		return self:AdjustWeightTree(root, key, addValue)
	end

	local newWeight = targetNode.originalWeight + addValue
	return self:AdjustWeightTree(root, key, newWeight)
end

function huffmanWeightTbl:GetTreeLength(root)
	if not root then return end

	return root.totalCount
end

-- This will not travaerse the root
function huffmanWeightTbl:_TraverseHuffmanTree(tree, level)

	if not tree then return end

	level = level or 0
	if tree.bIsLeaf then
		print(tree.key)
		return
	end

	print("level:",level,"left weight is",tree.leftWeight,"\n")

	local left = tree[1]
	local right = tree[2]

	self:_TraverseHuffmanTree(left, level + 1)
	self:_TraverseHuffmanTree(right, level + 1)
end

function huffmanWeightTbl:ShowHuffmanTree(root)
	if not root then return end
	self:_TraverseHuffmanTree(root.tree)
end

function huffmanWeightTbl:LoadAdjustableWeightTreeFromFile(filePath)
	local file = io.open(filePath, "rb")
	if not file then return end

	local tbl = {}
	for line in file:lines() do
		local key,value = string.match(line, "([^;]+)(;)([^;]+)")
		value = value and tonumber(value) or 0
		tbl[key] = value
	end

	return self:BuildHuffmanTree(tbl, true)

end

function huffmanWeightTbl:WriteWeightTreeToFile(root, filePath)
	local file = io.open(filePath, "w")
	if not file then return end

	if not root.bAdjustableTree then return end

	local treeIndex = root.treeIndex
	if not treeIndex then return end

	for k,v in pairs(treeIndex) do
		file:write(k..";"..v.originalWeight.."\n")
	end

	file:close()
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
