-- 工厂方法设计模式

-- require "class"

IItem = class()

function IItem:GetTemplateId()
	print("IItem GetTemplateId")
end

CItem = class(IItem)
 
function CItem:GetTemplateId()
	print("CItem GetTemplateId")
end

CEquipment = class(IItem)
function CEquipment:GetTemplateId()
	print("CEquipment GetTemplateId")
end

---------------
IFactory = class()
function IFactory:CreateItem()
	print("IFactory CreateItem")
end

ItemFactory = class(IFactory)
function ItemFactory:CreateItem()
	return CItem:new()
end

EquipmentFactory = class(IFactory)
function EquipmentFactory:CreateItem()
	return CEquipment:new()
end

-- 测试代码
function DoFactoryMethod(factory)
	if factory == nil then return end
	IHuman = factory:CreateItem()
	IHuman:GetTemplateId()
end

--- main ---
function FactoryMethodMain()
	print("----------")
	DoFactoryMethod(ItemFactory:new())
	print("----------")
	DoFactoryMethod(EquipmentFactory:new())
end
