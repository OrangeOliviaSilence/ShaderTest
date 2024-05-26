using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderTest : MonoBehaviour
{
    public Material material;

    // Start is called before the first frame update
    void Start()
    {
        print(material.shader.maximumLOD);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
            material.shader.maximumLOD = 10;
        else if (Input.GetKeyDown(KeyCode.S))
            material.shader.maximumLOD = 20;
        else if (Input.GetKeyDown(KeyCode.D))
            material.shader.maximumLOD = 5;
        else if (Input.GetKeyDown(KeyCode.F))
            material.shader.maximumLOD = 30;
        else if (Input.GetKeyDown(KeyCode.G))
            material.shader.maximumLOD = 15;
    }
}
