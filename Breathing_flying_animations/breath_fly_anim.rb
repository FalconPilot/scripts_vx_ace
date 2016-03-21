#==============================================================================
# ** Monsters_Breath
# * Script by FalconPilot
#------------------------------------------------------------------------------
#  This simple script allows to add a breathing effect to battlers
#during the combat (Scene_Battle)
#------------------------------------------------------------------------------
#  Thanks to Joke for the help with the Sinus equation ! :D
#==============================================================================

#==============================================================================
# ** Parameters
#------------------------------------------------------------------------------
#  This module can be modified to set the effects parameters
#==============================================================================

module FPL
  #--------------------------------------------------------------------------
  # * Insert monster IDs with breathing animation in this array
  #--------------------------------------------------------------------------
  BTH = [1, 2, 3]
  #--------------------------------------------------------------------------
  # * Breath effect parameters
  #--------------------------------------------------------------------------
  B_SPEED = 0.1     # Breath speed (Default = 0.1)
  B_VARIA = 0.1     # Breath amplitude (Default = 0.1)
  #--------------------------------------------------------------------------
  # * Insert monster IDs with flying animation in this array
  #--------------------------------------------------------------------------
  FLY = [1, 2, 3]
  #--------------------------------------------------------------------------
  # * Flying effect parameters
  #--------------------------------------------------------------------------
  F_SPEED = 0.1     # Flying speed (Default = 0.1)
  F_VARIA = 5       # Flying amplitude (Default = 5)
end

#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  The main code is here. Modify at your own risk !
#==============================================================================

class Sprite_Battler
  #--------------------------------------------------------------------------
  # * Update Aliasing
  #--------------------------------------------------------------------------
  alias_method :update_normal, :update
  def update
    update_normal
    if @battler && @use_sprite
      breath_effect if FPL::BTH.include?(@battler.enemy_id)
      fly_effect if FPL::FLY.include?(@battler.enemy_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Breathing Effect
  #--------------------------------------------------------------------------
  def breath_effect
    @breath_count = rand(6) if !@breath_count
    self.zoom_y = 1.0 + FPL::B_VARIA * Math.sin(@breath_count)
    @breath_count += FPL::B_SPEED
  end
  #--------------------------------------------------------------------------
  # * Flying Effect
  #--------------------------------------------------------------------------
  def fly_effect
    @base_y = self.y if !@base_y
    @fly_count = rand(6) if !@fly_count
    self.y = @base_y + FPL::F_VARIA * Math.sin(@fly_count)
    @fly_count += FPL::F_SPEED
  end
end

