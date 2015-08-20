#==============================================================================
# ** Display Element Rates in menu
#------------------------------------------------------------------------------
#  Script by FalconPilot / Script par FalconPilot
#  Merci de me créditer si vous l'utilisez, ou un esprit vengeur viendra vous
#  tuer dans votre sommeil
#
#  Merci à Nuki et Zangther pour les conseils/aides
#==============================================================================

#==============================================================================
# ** Module DName
#------------------------------------------------------------------------------
#  Modifiez ce module pour modifier les valeurs importantes du script
#==============================================================================
module Dname
  #--------------------------------------------------------------------------
  # * Diminutifs des statistiques dans Window_EquipStatus
  #--------------------------------------------------------------------------
  Datk = "ATK"          #Attaque
  Ddef = "DEF"          #Défense
  Dmag = "MAG"          #Magie
  Dres = "RES"          #Résistance magique
  Dagi = "AGI"          #Agilité
  Dluc = "LUC"          #Chance
end
#==============================================================================
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#  Monkeypatch for Window_EquipStatus
#==============================================================================

class Window_EquipStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 158
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 8
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    draw_current_param(x + 40, y, param_id) if @actor
    draw_right_arrow(x + 80, y)
    draw_new_param(x + 105, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # * Draw Parameter Name
  #--------------------------------------------------------------------------
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, get_param_name(param_id))
  end
  
  def get_param_name(param_id)
    if(param_id == 2)
      return Dname::Datk
    elsif(param_id == 3)
      return Dname::Ddef
    elsif(param_id == 4)
      return Dname::Dmag
    elsif(param_id == 5)
      return Dname::Dres
    elsif(param_id == 6)
      return Dname::Dagi
    elsif(param_id == 7)
      return Dname::Dluc
    else
      return "???"
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Current Parameter
  #--------------------------------------------------------------------------
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 32, line_height, @actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Right Arrow
  #--------------------------------------------------------------------------
  def draw_right_arrow(x, y)
    change_color(system_color)
    draw_text(x, y, 22, line_height, "→", 1)
  end
  #--------------------------------------------------------------------------
  # * Draw Post-Equipment Change Parameter
  #--------------------------------------------------------------------------
  def draw_new_param(x, y, param_id)
    new_value = @temp_actor.param(param_id)
    change_color(param_change_color(new_value - @actor.param(param_id)))
    draw_text(x, y, 32, line_height, new_value, 2)
  end
end
#==============================================================================
# ** Window_EquipItem
#------------------------------------------------------------------------------
#  Monkeypatch for Window_EquipItem
#==============================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # Status window
  attr_reader   :element_window           # Element window
  #--------------------------------------------------------------------------
  # * Set Status Window
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Set Element Window
  #--------------------------------------------------------------------------
  def element_window=(element_window)
    @element_window = element_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    super
    if @actor && @status_window && @element_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.force_change_equip(@slot_id, item)
      @status_window.set_temp_actor(temp_actor)
      @element_window.set_temp_actor(temp_actor)
    end
  end
end
#==============================================================================
# ** Window_ERates
#------------------------------------------------------------------------------
#  The element_rates window
#==============================================================================

class Window_ERates < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, window_height)
    @actor = nil
    @temp_actor = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * Reset element_rate
  #--------------------------------------------------------------------------
  def reset_rate
    @temp_actor = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    return 70
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_all if @actor
  end
  #--------------------------------------------------------------------------
  # * Set Temporary Actor After Equipment Change
  #--------------------------------------------------------------------------
  def set_temp_actor(temp_actor)
    return if @temp_actor == temp_actor
    @temp_actor = temp_actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Draw all
  #--------------------------------------------------------------------------
  def draw_all
    for i in 0..3
      @rate = @actor.element_rate(i+6) * 100 - 100
      @next_rate = @temp_actor.element_rate(i+6)*100 - 100 if @temp_actor
      draw_icon(104+i, 88*i, 0)
      draw_right_arrow(88*i-48, 25)
      draw_elem_rate(32+88*i, 0)
      draw_next_rate(32+88*i, 25) if @temp_actor
    end
  end
  #--------------------------------------------------------------------------
  # * Draw element rate
  #--------------------------------------------------------------------------
  def draw_elem_rate(x, y)
    @display = @rate.to_i.to_s
    change_color(normal_color)
    if @rate >= 0
      draw_text(x, y, 120, line_height, "+" + @display + "%")
    else
      draw_text(x, y, 120, line_height, @display + "%")
    end
  end
  #--------------------------------------------------------------------------
  # * Draw next element rate
  #--------------------------------------------------------------------------
  def draw_next_rate(x, y)
    @display_next = @next_rate.to_i.to_s
    change_color(param_change_color(@next_rate - @rate))
    if @next_rate >= 0
      draw_text(x, y, 120, line_height, "+" + @display_next + "%")
    else
      draw_text(x, y, 120, line_height, @display_next + "%")
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Right Arrow
  #--------------------------------------------------------------------------
  def draw_right_arrow(x, y)
    change_color(system_color)
    draw_text(x, y, 120, line_height, "→", 1)
  end
end
#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  The monkeypatch for Scene_Equip
#==============================================================================
class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Beginning of the scene
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_status_window
    create_element_window
    create_slot_window
    create_item_window
    command_equip
  end
  #--------------------------------------------------------------------------
  # * Status window
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_EquipStatus.new(0, @help_window.height)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # * Element rate window
  #--------------------------------------------------------------------------
  def create_element_window
    wx = @status_window.width
    wy = @help_window.height
    ww = Graphics.width - @status_window.width
    @element_window = Window_ERates.new(wx, wy, ww)
    @element_window.viewport = @viewport
    @element_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # * Slot window
  #--------------------------------------------------------------------------
  def create_slot_window
    wx = @status_window.width
    wy = @element_window.y + @element_window.height
    ww = Graphics.width - @status_window.width
    @slot_window = Window_EquipSlot.new(wx, wy, ww)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.status_window = @status_window
    @slot_window.actor = @actor
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Item window
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = @slot_window.y + @slot_window.height
    ww = Graphics.width
    wh = Graphics.height - wy
    @item_window = Window_EquipItem.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.element_window = @element_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # * Item [Cancel]
  #--------------------------------------------------------------------------
  def on_item_cancel
    @slot_window.activate
    @item_window.unselect
    @element_window.reset_rate
  end
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def on_item_ok
    Sound.play_equip
    @actor.change_equip(@slot_window.index, @item_window.item)
    @slot_window.activate
    @slot_window.refresh
    @item_window.unselect
    @item_window.refresh
    @element_window.refresh
    @element_window.reset_rate
  end
end
