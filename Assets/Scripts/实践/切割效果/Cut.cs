using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cut : MonoBehaviour
{
    public Material material;
    public GameObject cuttedObject;
    void Start()
    {
        material = GetComponent<Renderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        if (material != null && cuttedObject != null)
        {
            material.SetVector("_CuttingPos", cuttedObject.transform.position);
        }
    }
}
