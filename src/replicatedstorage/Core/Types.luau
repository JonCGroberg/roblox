--!strict

-- Game Service Types
export type PlayerState = {
	userId: number,
	joinedAt: number,
	isInitialized: boolean,
	data: { [string]: any },
}

export type GameState = {
	players: { [number]: PlayerState },
	isInitialized: boolean,
	startTime: number,
}

export type GameService = {
	_state: GameState,
	_dataStore: DataStore,

	Init: (self: GameService) -> (),
	GetPlayerState: (self: GameService, userId: number) -> PlayerState?,
	GetGameState: (self: GameService) -> GameState,
	SavePlayerData: (self: GameService, userId: number) -> boolean,
	LoadPlayerData: (self: GameService, userId: number) -> boolean,
}

-- UI Service Types
export type CurrencyType = "coins" | "gems"
export type TransactionType = "purchase" | "sale" | "transfer"
export type ResourceType = "raw" | "processed" | "special"

export type Screen = {
	Name: string,
	Instance: ScreenGui,
	_uiService: UIService,
	Show: (self: Screen) -> (),
	Hide: (self: Screen) -> (),
	Destroy: (self: Screen) -> (),
	UpdateCurrency: (self: Screen, coins: number, gems: number) -> ()?,
}

export type Component = {
	Name: string,
	Instance: Instance,
	Show: (self: Component) -> (),
	Hide: (self: Component) -> (),
	Destroy: (self: Component) -> (),
}

export type UIService = {
	Init: (self: UIService) -> (),
	RegisterScreen: (self: UIService, screen: Screen) -> (),
	RegisterComponent: (self: UIService, component: Component) -> (),
	GetScreen: (self: UIService, name: string) -> Screen?,
	GetComponent: (self: UIService, name: string) -> Component?,
	ShowScreen: (self: UIService, name: string, transition: string?) -> (),
	HideScreen: (self: UIService, name: string, transition: string?) -> (),
	ShowComponent: (self: UIService, name: string) -> (),
	HideComponent: (self: UIService, name: string) -> (),
}

-- Base Component Types
export type EventHandler = (self: BaseComponent, ...any) -> ()

export type BaseComponent = {
	Name: string,
	Instance: Instance,
	IsVisible: boolean,
	_events: { [string]: { EventHandler } },
	_uiService: UIService?,

	Show: (self: BaseComponent) -> (),
	Hide: (self: BaseComponent) -> (),
	Destroy: (self: BaseComponent) -> (),
	Update: (self: BaseComponent, data: any) -> (),
	On: (self: BaseComponent, event: string, handler: EventHandler) -> (),
	Off: (self: BaseComponent, event: string, handler: EventHandler) -> (),
	Emit: (self: BaseComponent, event: string, ...any) -> (),
}

-- Economy Types
export type Transaction = {
	id: string,
	type: TransactionType,
	amount: number,
	currency: CurrencyType,
	from: string?,
	to: string?,
	timestamp: number,
	metadata: { [string]: any }?,
}

export type PlayerEconomy = {
	coins: number,
	gems: number,
	transactionHistory: { Transaction },
	lastUpdated: number,
}

export type MarketPrice = {
	basePrice: number,
	currentPrice: number,
	lastUpdated: number,
	priceHistory: { number },
	supply: number,
	demand: number,
}

export type Resource = {
	id: string,
	name: string,
	type: ResourceType,
	basePrice: number,
	description: string,
	icon: string,
	stackSize: number,
	rarity: number,
}

export type ProcessingRecipe = {
	input: { [string]: number },
	output: { [string]: number },
	processingTime: number,
	facilityType: string,
}

export type Facility = {
	id: string,
	type: string,
	position: Vector3,
	rotation: Vector3,
	inputBuffer: { [string]: number },
	outputBuffer: { [string]: number },
	processingRate: number,
	efficiency: number,
}

export type Bot = {
	id: string,
	facilityId: string,
	position: Vector3,
	target: Vector3?,
	carrying: { [string]: number },
	speed: number,
	state: "idle" | "moving" | "loading" | "unloading",
}

export type EconomyService = {
	Init: (self: EconomyService) -> (),
	GetPlayerEconomy: (self: EconomyService, player: Player) -> PlayerEconomy?,
	AddCurrency: (self: EconomyService, player: Player, amount: number, currency: CurrencyType) -> boolean,
	RemoveCurrency: (self: EconomyService, player: Player, amount: number, currency: CurrencyType) -> boolean,
	TransferCurrency: (
		self: EconomyService,
		from: Player,
		to: Player,
		amount: number,
		currency: CurrencyType
	) -> boolean,
	OnCurrencyUpdated: BindableEvent,
}

export type MarketService = {
	Init: (self: MarketService) -> (),
	GetResourcePrice: (self: MarketService, resourceId: string) -> number?,
	UpdateResourcePrice: (self: MarketService, resourceId: string, newPrice: number) -> (),
	GetResourceSupply: (self: MarketService, resourceId: string) -> number?,
	GetResourceDemand: (self: MarketService, resourceId: string) -> number?,
	UpdateResourceSupply: (self: MarketService, resourceId: string, amount: number) -> (),
	UpdateResourceDemand: (self: MarketService, resourceId: string, amount: number) -> (),
	OnPriceUpdated: BindableEvent,
}

-- types are still exposed even with nil due to export
return nil
