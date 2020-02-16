// X2EventListener_DetailedSoldierList.uc
// 
// A listener template that integrates with Community Highlander events to
// customize how soldier statuses are displayed.
//
class X2EventListener_DetailedSoldierList extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// If CHL isn't loaded, break out of this function right away to avoid
	// UnrealEngine attempting to load classes it doesn't have access to.
	if (!class'X2DownloadableContentInfo_DetailedSoldierListWOTC'.default.IsRequiredCHLInstalled)
	{
		return Templates;
	}

	Templates.AddItem(CreateStatusListeners());

	return Templates;
}

static function CHEventListenerTemplate CreateStatusListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'SoldierStatusListeners');
	Template.AddCHEvent('OverridePersonnelStatusTime', OnOverridePersonnelStatusTime, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

// Converts Days to Hours if the time left on a soldier status is less than
// the class'UIPersonnel_SoldierListItemDetailed'.default.NUM_HOURS_TO_DAYS
// threshold.
//
// Note that this requires the `XComLWTuple` source file in Development/SrcOrig
// in order for this class to compile.
static function EventListenerReturn OnOverridePersonnelStatusTime(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID, Object CallbackData)
{
	local XComLWTuple			OverrideTuple;
	local XComGameState_Unit	UnitState;
	local int					Hours, Days;

	OverrideTuple = XComLWTuple(EventData);
	if (OverrideTuple == none)
	{
		`REDSCREEN("OverridePersonnelStatusTime event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(EventSource);
	if (UnitState == none)
	{
		`REDSCREEN("OverridePersonnelStatusTime event triggered with invalid source data.");
		return ELR_NoInterrupt;
	}

	Hours = OverrideTuple.Data[2].i;
	if (Hours < 0 || Hours > 24 * 30 * 12) // Ignore year long missions
	{
		OverrideTuple.Data[1].s = "";
		OverrideTuple.Data[2].i = 0;
		return ELR_NoInterrupt;
	}

	if (Hours > class'UIPersonnel_SoldierListItemDetailed'.default.NUM_HOURS_TO_DAYS)
	{
		Days = FCeil(float(Hours) / 24.0f);
		OverrideTuple.Data[1].s = class'UIUtilities_Text'.static.GetDaysString(Days);
		OverrideTuple.Data[2].i = Days;
	}
	else
	{
		OverrideTuple.Data[1].s = class'UIUtilities_Text'.static.GetHoursString(Hours);
		OverrideTuple.Data[2].i = Hours;
	}
}
