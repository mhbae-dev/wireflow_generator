try(destroydialog wireflow)catch() --if the rollout is already existing it will replace it with the new one (especially after evaluating the script again)
rollout wireflow "wireflow" --defining the rollout
(
	
global selectedobject 
global selectedobject1 = #()
global selectedobject2
global wrapobject 
global wrapoption
global emit = 70
global emit2 = 70
global thickness = 1
global width = 0.3
global end = 100 --defining the last frame at which splines will be generated
global incr = 5 --intervals at which particle positions will be taken to generate spline knots

radiobuttons choose_btn labels:#("Wrap One", "Wrap Multiple") align:#left enabled:true

pickButton SplineStart "Spline Start" width:140 align:#center enabled:false
edittext selectedobject_tf "Picked: " text: "None" readonly:true width:138
pickButton Attract "Attractors" width:140 align:#center enabled:false
edittext selectedobject1_tf "Picked: " text: "None" readonly:true width:138
pickButton SplineEnd "Spline End" width:140 align:#center enabled:false
edittext selectedobject2_tf "Picked: " text: "None" readonly:true width:138
spinner particle_spn "Num Particles" width:125 height:20 range:[1,200,emit] type:#integer
button generateflow_btn "Generate Flow" width:140 align:#center enabled:false

pickButton Wrap "Wrap One Object" width:140 align:#center
edittext wrapobject_tf "Picked: " text: "None" readonly:true width:138
spinner particle2_spn "Num Particles" width:125 height:20 range:[1,200,emit2] type:#integer --spinner for number of particles
button generatewrap_btn "Generate Wrap" width:140 align:#center enabled:false
	
radiobuttons knot_btn labels:#("smooth", "corner") align:#left --radio button with selection of either smooth or corner splines' property
spinner end_spn "End Frame" width:125 height:20 range:[1,10000,end] type:#integer --spinner for defining end frame
spinner incr_spn "Increments" width:125 height:20 range:[1,10000,incr] type:#integer --spinner for defining intervals at which splines are generated
button gen_btn "Generate Splines" width:125 height:20 enabled:false --generate button
button del_btn "Delete Old Splines" width:125 height:20 enabled:false --delete button
spinner spn_thick "Spline Thickness" width:110 range:[0,9999.0,thickness] type:#worldunits align:#center --spinner for spline thickness
spinner spn_width "Spline Width" pos:(spn_thick.pos + [-100,20]) fieldwidth:40 height:30 range:[0,9999.0,width] type:#worldunits enabled:false align:#center --spinner for rectangle width

radiobuttons circle_rectangle pos:(spn_thick.pos + [-111, 45]) labels:#("radial", "rectangular") align:#center
button thickness_btn "Generate Thickness" width:110 align:#center enabled:false
button clear_btn "Reset Everything" width:125 height:20 enabled:true --clear particle view button

pickButton Wrap2 "Pick Object" width:140 align:#center
edittext wrapoption_tf "Picked: " text: "None" readonly:true width:138
button generatewrap2_btn "Generate Wrap" width:140 align:#center enabled:false


--Wrapping fuction for multiple objects
fn GenerateFlow =
(
pf = PF_Source() --Creates a PF Source
pf.SetPViewLocation 110 70 --This sets the location of the PF Source in particle view
particleFlow.BeginEdit() --Begin editing in particle flow

rp1 = RenderParticles() --Creating a render particle action and calling it rp1 
pf.appendaction (rp1) --rp1 is then appended to PF Source 001

--Event 001 Creation
ev1 = Event()
ev1.SetPViewLocation 110 170  --This sets the location of the Event Box in particle view
ev1.appendaction (Birth())  --Creates a Birth action and adds it to Event 1 (This controls the number os particles created)
ev1.appendaction (Position_Object()) --Creates a Position Object action and appends it to Event 1 (Allows user to pick the position where the particles are emitted from)
ev1.appendaction (Speed()) --Creates a Speed action and appends it to Events 1 (controls the speed and direction of the moving particles) 
ft1 = Find_Target() -- Create Find Target action and call it ft1 (allows user to select an object or surface which the particles move towards)
ev1.appendaction (ft1) --Append ft1 to Event 001
ev1.appendaction (DisplayParticles color:blue) --Sets the color of the created particles to blue (can choose what the particles are displayed as including the color)
$'Birth 001'.emit_stop = 0 --selects Birth 001 and sets emit stop count to 0
$'Birth 001'.amount = emit --Name Birth 001 amount 'emit' so that it can be called when spinner is changed (changes the number of particles emitted)

$'Position Object 001'.emitter_objects.count = 0
$'Position Object 001'.emitter_objects = #(selectedobject) --Selects where the particles will be emitted from which is stored in selectedobject

$'Speed 001'.speed = 100 --setting speed to predetermined settings for best results
$'Speed 001'.direction = 3 --Sets the particles to be dispersed in a 'Random 3D' direction

$'Find Target 001'.target_objects.count = 0
$'Find Target 001'.target_objects = selectedobject1 --Selection of object that the particles will be attracted to which is stored in global selectedobject1
$'Find Target 001'.cruise_speed = 100 --setting speed to predetermined settings for best results
$'Find Target 001'.aim_point_type = 1 --changes the point in which the particles find/attract to first which we put as closest point
$'Find Target 001'.target_type = 1 --sets target type as mesh objects so that we can select objects
select ft1
hide ft1 --Hiding Find Target Icon
select pf
hide pf --Hiding the PF Source

--Event 002 Creation
ev2 = Event()  --Creates and Event into which actions can be added
ev2.setPViewLocation 118 386 --This sets the location of the Event Box in particle view
ev2.appendaction (Speed_By_Surface())  --Creates Speed By Surface action and adds it to the event
ev2.appendaction (Speed()) --Creates a Speed action and appends it to the Event
ev2.appendaction (DisplayParticles color:blue) --Sets the color of the created particles to blue
at1 = Age_Test() --Age test checks how long a particle has been existing in a event
ev2.appendaction (at1)  --Appends created age test to at1
$'Speed By Surface 001'.surface_objects.count = 0 
$'Speed By Surface 001'.surface_objects = selectedobject1 --This sets selectedobject 1 as the object to be affected by the speed by surface action
$'Speed By Surface 001'.speed_type = 1 --Set to Control speed continuously instead of Set speed once
$'Speed By Surface 001'.speed_value = 15 --setting speed to predetermined settings for best results
$'Speed By Surface 001'.direction_type = 2 --Setting particles to flow parallel to the surface of the object

$'Speed 002'.speed = 0.01 --setting speed to predetermined settings for best results
$'Speed 002'.direction = 3  --Sets the particles to be dispersed in a 'Random 3D' direction

$'Age Test 001'.test_value = 64000 --setting particle age test value to 400

--Event 3 Creation
ev3 = Event() --Creates and Event into which actions can be added
ev3.setPViewLocation 128 570 --This sets the location of the Event Box in particle view
ft2 = Find_Target() -- Create Find Target action and call it ft2
ev3.appendaction (ft2) --Append ft2 to the Event
ev3.appendaction (DisplayParticles color:blue) --Sets the color of the created particles to blue
$'Find Target 002'.target_objects.count = 0
$'Find Target 002'.target_objects = #(selectedobject2) --This uses what ever picked object is stored in selectedobject 2 as the end point of the particles
$'Find Target 002'.cruise_speed = 100 --setting speed to predetermined settings for best results
$'Find Target 002'.target_type = 1 --sets target type as mesh objects so that we can select objects
select ft2
hide ft2 --Select and Hide Find Target Icon

--Event 4 Creation
ev4 = Event() --Creates and Event into which actions can be added
ev4.setPViewLocation 140 690 --This sets the location of the Event Box in particle view
ev4.appendaction (Stop()) --Creates Stop action and appends it to the event this stops all particle movement
ev4.appendaction (DisplayParticles color:blue) --Sets the color of the created particles to blue
particleFlow.EndEdit() --End editing in particle flow

--link all the events together
pf.AppendInitialActionList ev1 --link PF Source 001 to Event 001
ft1.setNextActionList ev2 ft1 --link Find Target 001 to Event 002
at1.setNextActionList ev3 at1 --link Age Test 001 to Event 3
ft2.setNextActionList ev4 ft2 --link Find Target 002 to Event 4

--This is a necessary part of the script without it you cannot view the particles so you need to reload it using hold and fetch
--Pflow seems to have an error when created from within maxscript so holding and fetching the file seems to be the only thing that 
--solves this issue	(source: http://stackoverflow.com/questions/22553419/accessing-paticleindex-of-generated-pf-source)
holdMaxFile()
fetchMaxFile quiet:true

)

--wrapping function for one object 
fn wrapping = 
(
pf = PF_Source() 
pf.SetPViewLocation 110 70 

particleFlow.BeginEdit() 
rp1 = RenderParticles()  
pf.appendaction (rp1) 

--Event 1 Creation	
ev1 = Event() 
ev1.SetPViewLocation 110 170 
ev1.appendaction (Birth())
ev1.appendaction (Position_Object())
ev1.appendaction (Speed())
ev1.appendaction (Speed_By_Surface())
ev1.appendaction (DisplayParticles color:blue)
	
$'Birth 001'.emit_stop = 0
$'Birth 001'.amount = emit2

$'Position Object 001'.emitter_objects.count = 0
$'Position Object 001'.use_surface_offset = on
$'Position Object 001'.emitter_objects = #(wrapobject)
select pf
hide pf
	
$'Speed 001'.speed = 100
$'Speed 001'.direction = 3

$'Speed By Surface 001'.speed_value = 15
$'Speed By Surface 001'.speed_type = 1
$'Speed By Surface 001'.direction_type = 2
$'Speed By Surface 001'.surface_objects = #(wrapobject)
particleFlow.EndEdit()

pf.appendinitialactionlist ev1
	
--hold and fetch maxscript file or else pflow has an error and will not show particles
holdMaxFile()
fetchMaxFile quiet:true
)

fn Gen=
	(
	local pf = $'PF Source 001' --selecting our PFSource that will be generating wrapping
	local numParts = pf.numParticles() --ADDED: counting amount of particles that are used to generate splines; easier way than presented in the original script

    for i in 1 to numParts do --for every particle that is generated by our PF_Source
    (
        newShp = splineShape() --defining geometry of newShp
        addNewSpline newShp --starting a new spline
        newShp.name = ("ParticleSpline_" + i as string) --saving splines by adding 'i' to names. Then the splines will be easy to call by their names
		newShp.renderable=true --ADDED: disabling visibility of splines' thickness in renderer
		newShp.displayRenderMesh=false --ADDED: disabling visibility of splines' thickness in viewport
    )
    for t in 0 to (end/incr) do --the operation needs to be called for x=(total time of process/intervals of time)
    (
        sliderTime = (t * incr) --at the beginning of the loop the time slider is set to a correct frame so the particles are collected their changed positions
        for i in 1 to numParts do --every particle needs to be called and get their position checked in order to produce knots
        (
            pf.particleIndex = i --running through the list of particles and selecting a current particle to work with for the next steps
            pId = pf.particleID --tracking particle ID that is given at birth to every particle, this way the current particle will be tracked for the next steps
            if pId != 0 then  --when the ID is not equal to zero
            (
				ParticleSplineShp = execute ("$ParticleSpline_" + pId as string) --the new object is defined that calls for the saved spline starting points. ID is used as a permanent property of every particle
				case Knot_Btn.state of --ADDED: option to choose between two types of joining knots: smooth and corner; radio button cases
				(
                1: addKnot ParticleSplineShp 1 #smooth #curve pf.particlePosition --first and second case for the radio button
				2: addKnot ParticleSplineShp 1 #corner #curve pf.particlePosition --a knot is added to a spline, a particle of defined ID at its current position
				)
            ) -- when finished the loop is run again with t+1 as the particles need to move to their next positions
        ) -- when the slider is moved and particles changed their positions, the next particle is called and run through the process of collecting its position
    ) -- all knots are added and the loop is closed

    select $'ParticleSpline_*' --selecting all splines that have been generated by the loops
    updateShape $ --splines with added knots need updating
	) --splines are visible, end of the function
	
	
	--Function for selecting old splines and deleting them
fn Del=
	(
		select $'ParticleSpline_*'
		if $ != undefined do 
		(
		delete $ 
		)
	)
	
--Adding thickness to the selected splines by doing a Renderable Spline modifier	
fn AddThickness =
	(
		select $'ParticleSpline_*'
		if $ != undefined do 
		(
			$.render_renderable= true
			$.render_displayRenderMesh = true
			$.render_viewport_rectangular = false
			$.render_rectangular =false
			$.thickness = thickness
		)
	)

--Function for rectangular splines in Renderable Spline
fn Rectangular =
	(
		select $'ParticleSpline_*'
		if $ != undefined do 
		(
		$.render_renderable= true
		$.render_displayRenderMesh = true
		$.render_viewport_rectangular = true
		$.render_rectangular = true
		$.render_width = width
		$.render_length = thickness
		)
	)

--This is the function where we create the same effect as the splines but in particle flow itself. We generate particles according to its travel distance and give them a geometry. Then the step distance between the particles to reduced to be negligable and the result is that the plarticles look like splines.
--This part of the script was not necessary but we scripted it to show what can be done within particle flow and that we could have created the same effect as generating splines in a much shorter script
fn Wrapoption2 = 
(
pf = PF_Source()
pf.SetPViewLocation 110 70

particleFlow.BeginEdit() --Begin editing in particle flow
rp1 = RenderParticles()
pf.appendaction (rp1)

--Event 1 Creation
ev1 = Event()
ev1.SetPViewLocation 110 170
ev1.appendaction (Birth())
ev1.appendaction (Position_Object())
ev1.appendaction (Speed())
ev1.appendaction (Speed_By_Surface())
sp1 = Spawn()
ev1.appendaction (sp1)

$'Birth 001'.emit_stop = 0
$'Birth 001'.amount = 70

$'Position Object 001'.emitter_objects.count = 0
$'Position Object 001'.use_surface_offset = on
$'Position Object 001'.emitter_objects = #(wrapoption)
	
$'Speed 001'.speed = 100
$'Speed 001'.direction = 3

$'Speed By Surface 001'.speed_value = 15
$'Speed By Surface 001'.speed_type = 1
$'Speed By Surface 001'.direction_type = 2
$'Speed By Surface 001'.surface_objects = #(wrapoption)
	
$'Spawn 001'.spawn_type = 2
$'Spawn 001'.speed_inherited = 0
$'Spawn 001'.spawn_step_size = 0.1

--Event 2 Creation
ev2 = Event()
ev2.setPViewLocation 118 386
ev2.appendaction (ShapeLibrary())
ev2.appendaction (DisplayParticles color:white)

$'Shape 001'.type_3D = 15
$'Shape 001'.size = 0.5

$'Display 001'.type = 6
particleFlow.EndEdit()

pf.appendinitialactionlist ev1
sp1.setNextActionList ev2 sp1

select pf
hide pf
	
--hold and fetch maxscript file or else pflow has an error and will not show particles
holdMaxFile()
fetchMaxFile quiet:true
	
)

--This fuction allows us to clear all the events in particle flow as you can not reset particle flow. So we call all the Events created and delete them
fn ClearPF=
	(
		particleFlow.BeginEdit()
		particleFlow.delete $'PF Source 001'
		particleFlow.delete $'Event 001'
		particleFlow.delete $'Event 002'
		particleFlow.delete $'Event 003'
		particleFlow.delete $'Event 004'
		particleFlow.EndEdit()
	)
	
--When wrap one button is picked the buttons for wrap multiple are disabled and visa versa	
on choose_btn changed state do
	(
		case state of
		(
			1: (
					Wrap.enabled = 		true
					Attract.enabled = 		false
					SplineStart.enabled = 		false
					SplineEnd.enabled = 		false;\
				)
			2: (
					Wrap.enabled = 		false
					Attract.enabled = 		true
					SplineStart.enabled = 		true
					SplineEnd.enabled = 		true;\
				)
		)
	)


--Spline Start, Attract and End are the buttons for wrapping multiple objects. Until the SplineEnd button is clicked the  generateflow button is disabled.
on SplineStart picked obj do
			(
					wrap2.enabled= false
					generatewrap2_btn.enabled= false
					if obj != undefined do
				(
					selectedobject = obj
					selectedobject_tf.text = obj.name
					if selectedobject != undefined do
					(
						if selectedobject1.count != 0 do
						(
							if selectedobject2 != undefined do
							(
								generateflow_btn.enabled= true
							)
						)
					)
				)
			)
			
on Attract picked obj do
	(
		wrap2.enabled= false
		generatewrap2_btn.enabled= false
		if obj != undefined do
				(
					append selectedobject1 obj
					selectedobject1_tf.text = selectedobject1 as string
					messageBox ("Selected Objects:" + selectedobject1 as string) title:"Selected Array" beep:false
					if selectedobject != undefined do
					(
						if selectedobject1.count != 0 do
						(
							if selectedobject2 != undefined do
							(
								generateflow_btn.enabled= true
							)
						)
					)
				)
	)
	
on SplineEnd picked obj do
	(
		wrap2.enabled= false
		generatewrap2_btn.enabled= false
		if obj != undefined do
				(
					selectedobject2 = obj
					selectedobject2_tf.text = obj.name
					if selectedobject != undefined do
					(
						if selectedobject1.count != 0 do
						(
							if selectedobject2 != undefined do
							(
								generateflow_btn.enabled= true
							)
						)
					)
				)
	)
	
on particle_spn changed amt do --changes the number of particles emitted by the pf source
	(
		emit = amt
	)
	
on generateflow_btn pressed do --generates particle flow definition for wrapping multiple objects
	(
		GenerateFlow()
		gen_btn.enabled= true
		generateflow_btn.enabled= false
		choose_btn.enabled= false
		SplineStart.enabled= false
		SplineEnd.enabled= false
		Attract.enabled= false
		wrap2.enabled= false
		generatewrap2_btn.enabled= false
	)
	
-- For wrapping one Object we have buttons Wrap One Object and Generate wrap. Until Wrap One Object is clicked is the Generate wrap button enabled
on Wrap picked obj do
				(
					choose_btn.enabled= false
					wrap2.enabled= false
					if obj != undefined do
					(
					wrapobject = obj
					wrapobject_tf.text = obj.name
					if wrapobject != undefined do
					(
						generatewrap_btn.enabled= true
					)
					)
				)
				
on particle2_spn changed amt do --changes the number of particles emitted by the pf source
	(
		emit2 = amt
	)
	
on generatewrap_btn pressed do --creates particle flow definition for wrapping one object. Enabled ony when either Generate Wrap or Generate Flow have been pressed
(
	generatewrap_btn.enabled= false
	wrapping()
	gen_btn.enabled= true
)

on Gen_Btn pressed do -- generates splines from the particle flow movements
	(
	Gen()
	Gen_Btn.enabled= false
	Del_Btn.enabled= true
	thickness_btn.enabled = true
	Wrap2.enabled= false
	generatewrap2_btn.enabled= false
	select $'Part'*
	$.wirecolor= white
	deselect
	)
	
on Del_Btn pressed do --deletes created splines
	(
	
	Del()
	Gen_Btn.enabled= true
	Del_Btn.enabled= false
	thickness_btn.enabled = false
	)
	
on Clear_Btn pressed do --this button resets the scene to the original state. Any events created in particle flow are deleted and any splines generated before are also cleared.
	(
	choose_btn.enabled= true
	SplineStart.enabled= false
	Attract.enabled= false
	circle_rectangle.enabled= true
	SplineEnd.enabled= false
	generateflow_btn.enabled= false
	Wrap.enabled= true
	generatewrap_btn.enabled= false
	Gen_Btn.enabled= false
	Del_Btn.enabled= false
	thickness_btn.enabled = false
	ClearPF()
	Del()
	free selectedobject
	selectedobject1 = #()
	free selectedobject2
	selectedobject_tf.text= "None"
	selectedobject1_tf.text= "None"
	selectedobject2_tf.text= "None"
	free wrapobject
	wrapobject_tf.text= "None"
	choose_btn.state= 1
	free wrapoption
	wrap2.enabled= true
	wrapoption_tf.text = "None"
	generatewrap2_btn.enabled= false
	Del()
	)
	
on end_spn changed amt do --end spinner value changed
	(
		end = amt
	)
	
on incr_spn changed amt do --increments spinner value changed
	(
		incr = amt
	)
	
on spn_thick changed amt do --changes value of spline thickness
	(
		thickness = amt
	)
	
on spn_width changed amt do --changes width value
	(
		width = amt
	)
	
on thickness_btn pressed do
	(
		case circle_rectangle.state of 
			(
			1: AddThickness()
			2: Rectangular()
			)
	)
	
on circle_rectangle changed state do
	(
		case state of
		(
			1: (
					spn_width.enabled = 		false;\
				)
			2: (
					spn_width.enabled = 		true;\
				)
		)
	)

on Wrap2 picked obj do --creates particle flow definition for wrapping one object all within particle flow (extra option)
				(
					wrap.enabled= false
					choose_btn.enabled= false
					if obj != undefined do
					(
					wrapoption = obj
					wrapoption_tf.text = obj.name
					generatewrap2_btn.enabled= true
					)
				)
				
on generatewrap2_btn pressed do --creates particle 'splines' to see them growing around the object move the animation slider
(
	
	choose_btn.enabled= false
	SplineStart.enabled= false
	Attract.enabled= false
	SplineEnd.enabled= false
	generateflow_btn.enabled= false
	Wrap.enabled= false
	generatewrap_btn.enabled= false
	Gen_Btn.enabled= false
	Del_Btn.enabled= false
	thickness_btn.enabled= false
	generatewrap2_btn.enabled= false
	circle_rectangle.enabled= false
	Wrap2.enabled= false
	Wrapoption2()
)

)
createdialog wireflow height:650