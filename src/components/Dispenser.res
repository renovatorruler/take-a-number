// Dispenser.res - Drag-to-pull ticket dispenser component

// Style object helper
let makeStyle: {..} => ReactDOM.style = %raw(`function(s) { return s; }`)

// Pull threshold in pixels
let pullThreshold = 80

// Event helpers for touch/mouse position
let getClientY = (event: ReactEvent.Mouse.t): float => {
  Obj.magic(event)["clientY"]
}

let getTouchClientY = (event: ReactEvent.Touch.t): float => {
  let touches: array<{..}> = Obj.magic(event)["touches"]
  switch touches[0] {
  | Some(touch) => touch["clientY"]
  | None => 0.0
  }
}

// Raw JS for window event listeners
let addWindowListeners: ('a, 'b, 'c) => unit = %raw(`
  function(onMouseMove, onTouchMove, onEnd) {
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onEnd);
    window.addEventListener('touchmove', onTouchMove, { passive: true });
    window.addEventListener('touchend', onEnd);
  }
`)

let removeWindowListeners: ('a, 'b, 'c) => unit = %raw(`
  function(onMouseMove, onTouchMove, onEnd) {
    window.removeEventListener('mousemove', onMouseMove);
    window.removeEventListener('mouseup', onEnd);
    window.removeEventListener('touchmove', onTouchMove);
    window.removeEventListener('touchend', onEnd);
  }
`)

@react.component
let make = (~onPull: option<unit => unit>=?, ~isDisabled: bool=false) => {
  let (isDragging, setIsDragging) = React.useState(() => false)
  let (dragProgress, setDragProgress) = React.useState(() => 0.0)
  let startYRef = React.useRef(0.0)

  // Handle drag/touch start
  let handleStart = (clientY: float) => {
    if !isDisabled {
      setIsDragging(_ => true)
      startYRef.current = clientY
    }
  }

  let handleMouseDown = (e: ReactEvent.Mouse.t) => {
    ReactEvent.Mouse.preventDefault(e)
    handleStart(getClientY(e))
  }

  let handleTouchStart = (e: ReactEvent.Touch.t) => {
    handleStart(getTouchClientY(e))
  }

  // Handle drag/touch move
  let handleMove = (clientY: float) => {
    if isDragging && !isDisabled {
      let deltaY = clientY -. startYRef.current
      let progress = Math.min(Math.max(deltaY, 0.0), Float.fromInt(pullThreshold))
      setDragProgress(_ => progress)
    }
  }

  // Handle drag/touch end
  let handleEnd = () => {
    if isDragging && !isDisabled {
      setIsDragging(_ => false)

      if dragProgress >= Float.fromInt(pullThreshold) {
        switch onPull {
        | Some(fn) => fn()
        | None => ()
        }
      }

      setDragProgress(_ => 0.0)
    }
  }

  // Handle simple tap/click
  let handleClick = (_e: ReactEvent.Mouse.t) => {
    if !isDisabled && !isDragging && dragProgress <= 5.0 {
      switch onPull {
      | Some(fn) => fn()
      | None => ()
      }
    }
  }

  // Add global mouse/touch listeners when dragging
  React.useEffect2(() => {
    if isDragging {
      let handleGlobalMouseMove = (e: {..}) => {
        handleMove(e["clientY"])
      }

      let handleGlobalTouchMove = (e: {..}) => {
        let touches: array<{..}> = e["touches"]
        switch touches[0] {
        | Some(touch) => handleMove(touch["clientY"])
        | None => ()
        }
      }

      let handleGlobalEnd = _ => handleEnd()

      addWindowListeners(handleGlobalMouseMove, handleGlobalTouchMove, handleGlobalEnd)

      Some(
        () => {
          removeWindowListeners(handleGlobalMouseMove, handleGlobalTouchMove, handleGlobalEnd)
        },
      )
    } else {
      None
    }
  }, (isDragging, dragProgress))

  let progressPercent = dragProgress /. Float.fromInt(pullThreshold) *. 100.0
  let ticketOffset = Math.min(dragProgress *. 0.5, 40.0)

  let dispenserStyle = makeStyle({
    "cursor": isDisabled ? "not-allowed" : "grab",
    "opacity": isDisabled ? "0.7" : "1",
  })

  let ticketStyle = makeStyle({
    "transform": `translateY(${Float.toString(ticketOffset)}px)`,
    "opacity": Float.toString(progressPercent /. 100.0),
  })

  let innerTicketStyle = makeStyle({"padding": "0.75rem"})

  let innerContentStyle = makeStyle({
    "fontSize": "2rem",
    "fontWeight": "900",
    "textAlign": "center",
  })

  let pullIndicatorStyle = makeStyle({
    "position": "absolute",
    "bottom": "-30px",
    "left": "50%",
    "transform": "translateX(-50%)",
    "fontSize": "0.75rem",
    "color": "var(--color-gray)",
  })

  <div className="dispenser-container" dataTestId="dispenser">
    <div
      className={`dispenser ${isDisabled ? "disabled" : ""}`}
      onMouseDown=handleMouseDown
      onTouchStart=handleTouchStart
      onClick=handleClick
      style=dispenserStyle
      dataTestId="dispenser-pull-area">
      <div className="dispenser-label"> {React.string("Take a Number")} </div>
      <div className="dispenser-hint">
        {React.string(isDisabled ? "Please wait..." : "↓ Tap or drag down ↓")}
      </div>
      <div className="dispenser-slot" />
    </div>
    // Preview ticket emerging
    <div
      className={`ticket-emerging ${dragProgress > 0.0 ? "pulling" : ""}`}
      style=ticketStyle
      dataTestId="ticket-preview">
      <div className="paper-ticket" style=innerTicketStyle>
        <div style=innerContentStyle> {React.string("?")} </div>
      </div>
    </div>
    {isDragging
      ? <div className="pull-indicator" style=pullIndicatorStyle>
          {React.string(
            progressPercent >= 100.0
              ? "Release!"
              : `Pull... ${Int.toString(Float.toInt(Math.round(progressPercent)))}%`,
          )}
        </div>
      : React.null}
  </div>
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Dispenser", make)
}
