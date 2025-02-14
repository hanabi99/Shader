using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class ButtonTest : MonoBehaviour,IPointerClickHandler
{
    public void OnPointerClick(PointerEventData eventData)
    {
        GameObject go = ExecuteEvents.GetEventHandler<IEventSystemHandler>(gameObject.transform.parent.gameObject);
        ExecuteEvents.Execute(go, eventData, ExecuteEvents.pointerClickHandler);
    }
}
