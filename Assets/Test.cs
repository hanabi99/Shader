using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    private RectTransform _rectTransform;
    void Start()
    {
        _rectTransform = GetComponent<RectTransform>();
        Debug.Log(_rectTransform.position);
        Debug.Log(_rectTransform.localPosition);
        Debug.Log(transform.localPosition);
        Debug.Log(transform.position);
    }
    
}
