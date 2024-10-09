const container = document.querySelector(".container");
const containerSkins = document.querySelector(".container-skins");
const buttonClose = document.querySelector("#button-close");
const inputSearch = document.querySelector("#inputSearch");
const buttonSearch = document.querySelector("#buttonSearch");

const ArraySkins = [];

function CreateSkin(img, name, id) {
  const divE = document.createElement("div");
  divE.classList = "skin";
  const imageE = document.createElement("img");
  imageE.src = `./img/${img}`;
  divE.appendChild(imageE);
  const pE = document.createElement("p");
  pE.innerText = name;
  divE.appendChild(pE);
  containerSkins.appendChild(divE);
  const bE = document.createElement("button");
  bE.id = id;
  bE.innerText = "USAR";
  bE.addEventListener("click", (e) => {
    fetch(`https://${GetParentResourceName()}/setskin`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        id: e.target.id,
      }),
    }).then((resp) => {
      resp.json();
    });
    fetch(`https://${GetParentResourceName()}/buttonclose`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        panel: false,
      }),
    }).then((resp) => {
      resp.json();
    });
    container.style.display = "none";
    containerSkins.innerHTML = "";
  });
  divE.appendChild(bE);
}

window.addEventListener("message", (event) => {
  if (event.data.img && event.data.name && event.data.id) {
    let obj = {
      img: event.data.img,
      name: event.data.name,
      id: event.data.id,
    };
    ArraySkins.push(obj);
  }
  if (event.data.open) {
    container.style.display = "flex";
    ArraySkins.forEach((item) => {
      CreateSkin(item.img, item.name, item.id);
    });
  } else {
    container.style.display = "none";
  }
});

buttonClose.addEventListener("click", () => {
  fetch(`https://${GetParentResourceName()}/buttonclose`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify({
      panel: false,
    }),
  }).then((resp) => {
    resp.json();
  });
  container.style.display = "none";
  containerSkins.innerHTML = "";
});

function filtrarItens() {
  const searchTerm = inputSearch.value.toLowerCase();
  containerSkins.innerHTML = "";
  const filteredItems = ArraySkins.filter((item) => item.name.toLowerCase().includes(searchTerm));
  filteredItems.forEach((item) => {
    CreateSkin(item.img, item.name, item.id);
  });
}

inputSearch.addEventListener("input", () => {
  filtrarItens();
});

buttonSearch.addEventListener("click", () => {
  filtrarItens();
});
