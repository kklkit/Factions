class FCrawler extends UDKPawn;

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=20.0
		CollisionHeight=5.0
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bSynthesizeSHLight=True
		bIsCharacterLightEnvironment=True
		bUseBooleanEnvironmentShadowing=False
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=0.2
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMesh0
		SkeletalMesh=SkeletalMesh'CH_Crawler.Mesh.SK_CH_Crawler'
		PhysicsAsset=PhysicsAsset'CH_Crawler.Mesh.SK_CH_Crawler_Physics'
		AnimTreeTemplate=AnimTree'CH_Crawler.Anims.AT_Crawler'
		AnimSets(0)=AnimSet'CH_Crawler.Anims.K_Crawler'
		LightEnvironment=LightEnvironment0
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=True)
		BlockRigidBody=True
		bHasPhysicsAssetInstance=True
		bEnableFullAnimWeightBodies=True
		bOwnerNoSee=True
		CastShadow=True
		bCastDynamicShadow=true
	End Object
	Mesh=SkeletalMesh0
	Components.Add(SkeletalMesh0)

	GroundSpeed=200.0
}
