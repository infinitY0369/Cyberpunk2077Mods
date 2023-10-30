@replaceMethod(CrafringMaterialItemController)
  public final func RefreshUI() -> Void {
    inkTextRef.SetText(this.m_nameText, this.m_data.m_displayName);
    inkTextRef.SetText(this.m_quantityText, IntToString(this.m_data.m_quantity));
    this.m_quantity = this.m_data.m_quantity;
    InkImageUtils.RequestSetImage(this, this.m_icon, this.m_data.m_iconPath);
    if this.m_data.m_quantity <= 0 {
      this.GetRootWidget().SetState(n"Empty");
    };
  }

@replaceMethod(InventoryItemDisplayController)
  protected func UpdateQuantity() -> Void {
    let countTreshold: Int32;
    let quantityText: String;
    let displayQuantityText: Bool = false;
    let itemInventory: InventoryItemData = this.GetItemData();
    let itemType: gamedataItemType = InventoryItemData.GetItemType(itemInventory);
    inkWidgetRef.SetVisible(this.m_quantintyAmmoIcon, false);
    countTreshold = Equals(this.m_itemDisplayContext, ItemDisplayContext.DPAD_RADIAL) ? 0 : 1;
    if !InventoryItemData.IsEmpty(itemInventory) {
      if InventoryItemData.GetQuantity(itemInventory) > countTreshold || Equals(itemType, gamedataItemType.Con_Ammo) {
        quantityText = IntToString(InventoryItemData.GetQuantity(itemInventory));
        inkTextRef.SetText(this.m_quantityText, quantityText);
        displayQuantityText = true;
      } else {
        if Equals(InventoryItemData.GetEquipmentArea(itemInventory), gamedataEquipmentArea.Weapon) {
          if InventoryItemData.GetGameItemData(itemInventory).HasTag(n"MeleeWeapon") {
            displayQuantityText = false;
          } else {
            quantityText = IntToString(InventoryItemData.GetAmmo(itemInventory));
            inkWidgetRef.SetVisible(this.m_quantintyAmmoIcon, true);
            inkTextRef.SetText(this.m_quantityText, quantityText);
            displayQuantityText = true;
          };
        };
      };
    };
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) && Equals(itemType, gamedataItemType.Con_Ammo) {
      quantityText = IntToString(CraftingSystem.GetAmmoBulletAmount(ItemID.GetTDBID(InventoryItemData.GetID(this.m_recipeData.inventoryItem))));
      inkTextRef.SetText(this.m_quantityText, quantityText);
      inkWidgetRef.SetVisible(this.m_quantintyAmmoIcon, true);
      displayQuantityText = true;
    };
    if Equals(itemType, gamedataItemType.Con_Inhaler) || Equals(itemType, gamedataItemType.Con_Injector) || Equals(itemType, gamedataItemType.Gad_Grenade) || Equals(itemType, gamedataItemType.Cyb_Launcher) {
      if Equals(this.m_itemDisplayContext, ItemDisplayContext.DPAD_RADIAL) || Equals(this.m_itemDisplayContext, ItemDisplayContext.GearPanel) {
        quantityText = IntToString(InventoryItemData.GetQuantity(itemInventory));
        inkTextRef.SetText(this.m_quantityText, quantityText);
        displayQuantityText = true;
      } else {
        displayQuantityText = false;
      };
    };
    if Equals(itemType, gamedataItemType.Cyb_Ability) {
      displayQuantityText = false;
    };
    inkWidgetRef.SetVisible(this.m_quantityText, displayQuantityText);
    inkWidgetRef.SetVisible(this.m_quantityWrapper, displayQuantityText);
  }
