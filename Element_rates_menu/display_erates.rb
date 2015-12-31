#==============================================================================
# ** Display Element Rates in menu
#------------------------------------------------------------------------------
#
#  Script by FalconPilot / Script par FalconPilot
#  Voici venu le temps des félons.
#
#  Merci à Nuki et Zangther pour les conseils/aides
#  Thanks to Nuki and Zangther for the tips/help
#
#------------------------------------------------------------------------------
#
#  Disclaimer : This script is old and kinda flawed. However, I'll be
#  leaving it here for those who still would like to use it.
#
#==============================================================================

#==============================================================================
# ** Module Drates
#------------------------------------------------------------------------------
#  Modifiez ce module pour modifier les valeurs importantes du script
#==============================================================================
module Drates
  #--------------------------------------------------------------------------
  # * Valeurs importantes
  #--------------------------------------------------------------------------
  MENU_ACT = true                     #Activation du menu custom
  #--------------------------------------------------------------------------
  # * Diminutifs des statistiques dans Window_EquipStatus
  #--------------------------------------------------------------------------
  DATK = "ATK"                        #Attaque
  DDEF = "DEF"                        #Défense
  DMAG = "MAG"                        #Magie
  DRES = "RES"                        #Résistance magique
  DAGI = "AGI"                        #Agilité
  DLUC = "LUC"                        #Chance
  #--------------------------------------------------------------------------
  # * Informations sur les éléments
  #--------------------------------------------------------------------------
  ELEM_COUNT = 4                     #Nombre d'éléments à afficher (Max 4)
  ELEM_ID =   [6, 7, 8, 9]           #ID des éléments affichés
  ELEM_ICON = [104, 105, 106, 107]   #Index des icônes
end
#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  Aliases of Scene_Menu
#==============================================================================
class Scene_Menu
  #--------------------------------------------------------------------------
  # * Old Scene_Equip alias
  #--------------------------------------------------------------------------
  alias_method :default_personal_ok, :on_personal_ok
  #--------------------------------------------------------------------------
  # * [OK] Personal Command
  #--------------------------------------------------------------------------
  def on_personal_ok
    if Drates::MENU_ACT && @command_window.current_symbol == :equip
      SceneManager.call(Scene_Equip_Elem)
    else
      default_personal_ok
    end
  end
end
#==============================================================================
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#  Window_EquipStatus overhaul to avoid overwriting the default one
#==============================================================================
class Window_EquipStatus_Elem < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @actor = nil
    @temp_actor = nil
    refresh
  end
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
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_name(@actor, 4, 0) if @actor
    6.times {|i| draw_item(0, line_height * (1 + i), 2 + i) }
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
  #--------------------------------------------------------------------------
  # * Get Parameter Name diminutive
  #--------------------------------------------------------------------------
  def get_param_name(param_id)
    case param_id
      when 2; return Drates::DATK
      when 3; return Drates::DDEF
      when 4; return Drates::DMAG
      when 5; return Drates::DRES
      when 6; return Drates::DAGI
      when 7; return Drates::DLUC
      else    return "???"
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
  attr_reader   :weapon_window            # Weapon elem window
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
  # * Set Weapon Window
  #--------------------------------------------------------------------------
  def weapon_window=(weapon_window)
    @weapon_window = weapon_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    super
    if @weapon_window
      @weapon_window.clear
      @weapon_window.set_weapon(item)
    end
    if @actor && @status_window || @element_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.force_change_equip(@slot_id, item)
      @status_window.set_temp_actor(temp_actor) if @status_window
      @element_window.set_temp_actor(temp_actor) if @element_window
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
    0.upto(Drates::ELEM_COUNT - 1) do |i|
      @elemid = Drates::ELEM_ID[i]
      @rate = (@actor.element_rate(@elemid)*100-100)*-1
      @next_rate = (@temp_actor.element_rate(@elemid)*100-100)*-1 if @temp_actor
      draw_icon(Drates::ELEM_ICON[i], 88*i, 0)
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
# ** Window_Help_Alt
#------------------------------------------------------------------------------
#  New help window for equip_elem
#==============================================================================
class Window_Help_Alt < Window_Base
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  def initialize(line_number=2)
    super(0, 0, Graphics.width * 0.7, fitting_height(line_number))
  end
  #--------------------------------------------------------------------------
  # * Set Text
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # * Set Item
  #     item : Skills and items etc.
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text(item ? item.description : "")
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
end
#==============================================================================
# ** Window_Weapon_Elem
#------------------------------------------------------------------------------
#  Window displaying weapon element
#==============================================================================
class Window_Weapon_Elem < Window_Base
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  def initialize(line_number=2)
    super(Graphics.width * 0.7 + 1, 0, Graphics.width * 0.3, fitting_height(line_number))
  end
  #--------------------------------------------------------------------------
  # * Set text
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Clearing
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # * Set weapon text
  #--------------------------------------------------------------------------
  def set_weapon(item)
    if (item)
      if (item.is_a?(RPG::Weapon))
        text = ""
        elem = item.features
        elem.each do |e|
          if (e.code == 31)
            text += elements[e.data_id].name
          end
        end
        set_text("#{text}")
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
end
#==============================================================================
# ** Scene_Equip_Elem
#------------------------------------------------------------------------------
#  New Scene_Equip to avoid overwriting the default one
#==============================================================================
class Scene_Equip_Elem < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Beginning of the scene
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_weapon_window
    create_status_window
    create_element_window
    create_slot_window
    create_item_window
    command_equip
  end
  #--------------------------------------------------------------------------
  # * Help window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help_Alt.new
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Weapon elem window
  #--------------------------------------------------------------------------
  def create_weapon_window
    @weapon_window = Window_Weapon_Elem.new
    @weapon_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Status window
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_EquipStatus_Elem.new(0, @help_window.height)
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
    @slot_window.set_handler(:pagedown, method(:next_actor))
    @slot_window.set_handler(:pageup,   method(:prev_actor))
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
    @item_window.weapon_window = @weapon_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # * [Change Equipment] Command
  #--------------------------------------------------------------------------
  def command_equip
    @slot_window.activate
    @slot_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * Slot [OK]
  #--------------------------------------------------------------------------
  def on_slot_ok
    @item_window.activate
    @item_window.select(0)
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
  #--------------------------------------------------------------------------
  # * Change Actors
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    @slot_window.actor = @actor
    @item_window.actor = @actor
    @element_window.actor = @actor
    @element_window.refresh
    @slot_window.activate
  end
end
